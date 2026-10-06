local Translations = {
    error = {
        not_teacher = 'You must be a teacher',
        not_clocked_in = 'You must be clocked in first',
        already_clocked_in = 'You are already clocked in!',
        not_clocked_in_clock = 'You are not clocked in!',
        class_cooldown = 'You must wait before starting another class (%{seconds}s remaining)',
        no_students = 'No students are seated! Wait for students to sit down first.',
        class_in_progress = 'A class is already in progress!',
        not_seated = 'You must be seated on a stool first',
    },
    success = {
        clocked_in = 'Clocked In',
        clocked_in_desc = 'You are now teaching at ~#4CAF50~%{school}~e~!',
        clocked_out = 'Clocked Out',
        clocked_out_desc = 'You have finished your shift at ~#4CAF50~%{school}~e~.',
        class_started = 'Class Started',
        class_started_desc = 'Open your books and learn something new!',
        class_complete = 'Class Complete',
        class_complete_desc = 'Well done! You earned ~#4CAF50~%{xp} XP~e~!',
        xp_increased = 'XP Increased',
        xp_increased_desc = 'You earned ~#4CAF50~%{xp} XP~e~ from school!',
        seated = 'Seated',
        seated_desc = 'You sat down. Wait for the teacher to start class!',
    },
    label = {
        clock_in = 'Clock In',
        clock_out = 'Clock Out',
        start_class = 'Start Class',
        top_of_class = 'Top of Class',
        learn_something = 'Learn Something New',
        teacher_menu = 'Teacher Menu',
        leaderboard = 'School Leaderboard',
        close = 'Close',
        reading = 'Reading...',
        target_clock_in = 'Clock In (Teacher)',
        target_clock_out = 'Clock Out (Teacher)',
        target_start_class = 'Start Class',
        target_top_of_class = 'Top of Class',
        target_sit_down = 'Learn Something New',
    },
    notify = {
        school_open = '%{school} is OPEN - Teacher on Duty!',
        school_closed = '%{school} is CLOSED - No Teacher Available',
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
