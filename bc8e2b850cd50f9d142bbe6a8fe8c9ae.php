<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify Your Email - Skill-Link</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f7f7f7;
            margin: 0;
            padding: 0;
            color: #333;
        }
        .container {
            max-width: 600px;
            margin: 20px auto;
            background-color: #ffffff;
            border: 1px solid #e5e5e5;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        .header {
            background-color: #4CAF50;
            padding: 20px;
            text-align: center;
            color: #ffffff;
        }
        .header h1 {
            margin: 0;
            font-size: 24px;
        }
        .content {
            padding: 20px;
        }
        .content h2 {
            color: #4CAF50;
            font-size: 32px;
            text-align: center;
            margin: 0;
        }
        .footer {
            background-color: #f1f1f1;
            text-align: center;
            padding: 10px;
            font-size: 12px;
            color: #666;
        }
        .footer a {
            color: #4CAF50;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Skill-Link Email Verification</h1>
        </div>
        <div class="content">
            <p>Dear User, <?php echo e($user->name); ?></p>
            <p>Thank you for signing up with Skill-Link! To complete your registration, please verify your email address using the One-Time Password (OTP) below:</p>
            <h2><?php echo e($otp); ?></h2>
            <p>This OTP is valid for <strong>10 minutes</strong>. Please enter it on the verification page to proceed.</p>
            <p>If you did not request this email, please disregard it. Your account will not be activated without email verification.</p>
            <p>Best regards,<br>The Skill-Link Team</p>
        </div>
        <div class="footer">
            <p>Need help? Visit our <a href="<?php echo e(url('/support')); ?>">Support Center</a> or contact us at <a href="mailto:support@haazirapp.com">support@haazirapp.com</a>.</p>
            <p>&copy; <?php echo e(date('Y')); ?> Skill-Link. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
<?php /**PATH C:\Users\sanau\Downloads\New folder\HaazirApp\resources\views\email\signupotp.blade.php ENDPATH**/ ?>