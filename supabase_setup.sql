-- Supabase Reminders Table Setup
-- Run this SQL in your Supabase SQL Editor to create the reminders table

-- Create reminders table
CREATE TABLE IF NOT EXISTS reminders (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    title TEXT NOT NULL,
    time TIMESTAMP WITH TIME ZONE NOT NULL,
    repeat TEXT NOT NULL CHECK (repeat IN ('none', 'daily', 'weekly', 'monthly')),
    is_done BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_reminders_user_id ON reminders(user_id);
CREATE INDEX IF NOT EXISTS idx_reminders_time ON reminders(time);
CREATE INDEX IF NOT EXISTS idx_reminders_is_done ON reminders(is_done);

-- Enable Row Level Security (RLS)
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to see only their own reminders
CREATE POLICY "Users can view their own reminders" 
    ON reminders FOR SELECT 
    USING (auth.uid() = user_id);

-- Create policy to allow users to insert their own reminders
CREATE POLICY "Users can insert their own reminders" 
    ON reminders FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Create policy to allow users to update their own reminders
CREATE POLICY "Users can update their own reminders" 
    ON reminders FOR UPDATE 
    USING (auth.uid() = user_id);

-- Create policy to allow users to delete their own reminders
CREATE POLICY "Users can delete their own reminders" 
    ON reminders FOR DELETE 
    USING (auth.uid() = user_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_reminders_updated_at 
    BEFORE UPDATE ON reminders 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Note: The app uses anonymous authentication by default.
-- If you want to use email/password authentication, you'll need to:
-- 1. Enable Email authentication in Supabase Authentication settings
-- 2. Update the app to use signInWithPassword instead of signInAnonymously
