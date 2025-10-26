-- Create prescriptions table for QR code authentication
CREATE TABLE IF NOT EXISTS prescriptions (
    id TEXT PRIMARY KEY,
    patient_name TEXT NOT NULL,
    doctor_name TEXT NOT NULL,
    diagnosis TEXT,
    medicines TEXT NOT NULL,
    qr_data TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled')),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    doctor_id UUID REFERENCES auth.users(id),
    verified_count INTEGER DEFAULT 0,
    last_verified_at TIMESTAMP WITH TIME ZONE
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_prescriptions_qr_data ON prescriptions(qr_data);
CREATE INDEX IF NOT EXISTS idx_prescriptions_status ON prescriptions(status);
CREATE INDEX IF NOT EXISTS idx_prescriptions_expires_at ON prescriptions(expires_at);

-- Enable Row Level Security
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;

-- Create policies for prescriptions table
-- Doctors can create and view their own prescriptions
CREATE POLICY "Doctors can manage their prescriptions" ON prescriptions
    FOR ALL USING (auth.uid() = doctor_id);

-- Allow authenticated users to verify prescriptions (read-only for verification)
CREATE POLICY "Authenticated users can verify prescriptions" ON prescriptions
    FOR SELECT USING (auth.role() = 'authenticated');

-- Function to automatically update prescription status when expired
CREATE OR REPLACE FUNCTION update_expired_prescriptions()
RETURNS void AS $$
BEGIN
    UPDATE prescriptions
    SET status = 'expired'
    WHERE expires_at < NOW() AND status = 'active';
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to run the function periodically (you can set this up in a cron job)
-- For now, we'll call it manually when needed

-- Insert some sample data for testing (optional)
-- INSERT INTO prescriptions (id, patient_name, doctor_name, diagnosis, medicines, qr_data, status, expires_at, doctor_id)
-- VALUES (
--     'RX1730419200000',
--     'John Doe',
--     'Dr. Smith',
--     'Common Cold',
--     'Paracetamol 500mg\nCetirizine 10mg',
--     'base64encodeddatahere',
--     'active',
--     NOW() + INTERVAL '30 days',
--     'doctor-uuid-here'
-- );
