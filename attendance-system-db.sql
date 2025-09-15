-- create_attendance_db.sql
-- Creates enums and tables for the Attendance System

BEGIN;

-- Create ENUM types (if they don't already exist)
DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'role_type') THEN
      CREATE TYPE role_type AS ENUM ('teacher','admin');
   END IF;
   IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'attendance_status_type') THEN
      CREATE TYPE attendance_status_type AS ENUM ('Present','Absent','Late');
   END IF;
   IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'attendance_method_type') THEN
      CREATE TYPE attendance_method_type AS ENUM ('QR','FaceRecognition','Manual');
   END IF;
   IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'report_type') THEN
      CREATE TYPE report_type AS ENUM ('Daily','Monthly','Custom');
   END IF;
   IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'device_type') THEN
      CREATE TYPE device_type AS ENUM ('Mobile','Tablet','Camera');
   END IF;
END$$;

-- Teachers table
CREATE TABLE IF NOT EXISTS teachers (
    teacher_id    SERIAL PRIMARY KEY,
    first_name    VARCHAR(50)            NOT NULL,
    last_name     VARCHAR(50),
    email         VARCHAR(100)           UNIQUE,
    password_hash VARCHAR(255),
    role          role_type              NOT NULL DEFAULT 'teacher',
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Classes table
CREATE TABLE IF NOT EXISTS classes (
    class_id    SERIAL PRIMARY KEY,
    class_name  VARCHAR(50)              NOT NULL,
    teacher_id  INTEGER,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT now(),
    CONSTRAINT fk_classes_teacher
        FOREIGN KEY(teacher_id) REFERENCES teachers(teacher_id) ON DELETE SET NULL
);

-- Students table
CREATE TABLE IF NOT EXISTS students (
    student_id       SERIAL PRIMARY KEY,
    first_name       VARCHAR(50)                        NOT NULL,
    last_name        VARCHAR(50),
    class_id         INTEGER                            NOT NULL,
    roll_number      VARCHAR(20),
    qr_code          VARCHAR(255)                       UNIQUE,
    face_embedding   BYTEA,            -- store binary embedding (128D) OR change to JSONB if preferred
    created_at       TIMESTAMP WITH TIME ZONE DEFAULT now(),
    CONSTRAINT fk_students_class
        FOREIGN KEY(class_id) REFERENCES classes(class_id) ON DELETE CASCADE
);

-- Attendance table
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id   SERIAL PRIMARY KEY,
    student_id      INTEGER               NOT NULL,
    class_id        INTEGER               NOT NULL,
    date            DATE                  NOT NULL,
    status          attendance_status_type NOT NULL,
    marked_by       INTEGER,
    method          attendance_method_type NOT NULL,
    timestamp       TIMESTAMP WITH TIME ZONE DEFAULT now(),
    CONSTRAINT fk_attendance_student
        FOREIGN KEY(student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_attendance_class
        FOREIGN KEY(class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    CONSTRAINT fk_attendance_markedby
        FOREIGN KEY(marked_by) REFERENCES teachers(teacher_id) ON DELETE SET NULL
);

-- Reports table
CREATE TABLE IF NOT EXISTS reports (
    report_id     SERIAL PRIMARY KEY,
    class_id      INTEGER,
    generated_on  TIMESTAMP WITH TIME ZONE DEFAULT now(),
    report_type   report_type,
    file_path     VARCHAR(255),
    CONSTRAINT fk_reports_class
        FOREIGN KEY(class_id) REFERENCES classes(class_id) ON DELETE SET NULL
);

-- Devices table
CREATE TABLE IF NOT EXISTS devices (
    device_id     SERIAL PRIMARY KEY,
    school_name   VARCHAR(100),
    device_type   device_type,
    registered_by INTEGER,
    registered_on TIMESTAMP WITH TIME ZONE DEFAULT now(),
    CONSTRAINT fk_devices_registeredby
        FOREIGN KEY(registered_by) REFERENCES teachers(teacher_id) ON DELETE SET NULL
);

-- Useful indexes
CREATE INDEX IF NOT EXISTS idx_students_class_id ON students(class_id);
CREATE INDEX IF NOT EXISTS idx_attendance_student_date ON attendance(student_id, date);
CREATE INDEX IF NOT EXISTS idx_attendance_class_date ON attendance(class_id, date);
CREATE INDEX IF NOT EXISTS idx_devices_school_name ON devices(school_name);

COMMIT;
