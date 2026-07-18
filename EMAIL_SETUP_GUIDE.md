# 📧 Firebase Email Setup Guide

Complete guide to configure Firebase email templates for user authentication.

## Overview

Firebase Authentication automatically handles email sending for:
- **Email Verification** - When users sign up with email/password
- **Password Reset** - When users request to reset their password
- **Email Change** - When users change their email address
- **MFA Enrollment** - Notification when user enables SMS MFA

All templates are managed in the Firebase Console and can be customized per your brand.

---

## 1. Firebase Console Configuration

### Step 1: Access Email Templates

1. Go to **[Firebase Console](https://console.firebase.google.com)**
2. Select your project: **ngoding-lok**
3. Navigate to **Authentication** → **Templates** (in left sidebar)
4. Select **English** language (or add more languages)

### Step 2: View Available Templates

You'll see 5 email templates:

| Template | When Sent | Purpose |
|----------|-----------|---------|
| **Email Address Verification** | User signs up or requests re-verification | Verify email ownership |
| **Password Reset** | User clicks "Forgot Password" | Allow password reset |
| **Email Address Change** | User requests to change email | Confirm new email address |
| **Multi-Factor Authentication Enrollment** | User enables SMS MFA | Security notification |
| **Custom Action** | Developer triggered | Custom actions (optional) |

---

## 2. Email Verification Template

### Current Template

```
Subject: Verify your email for %APP_NAME%

Message:
Hello %DISPLAY_NAME%,

Follow this link to verify your email address.

%LINK%

If you didn't ask to verify this address, you can ignore this email.

Thanks,
Your %APP_NAME% team
```

### How to Customize

1. Click **Email Address Verification** template
2. Edit **Subject Line**:
   ```
   Welcome to %APP_NAME%! Verify your email
   ```

3. Edit **Message** with brand styling:
   ```html
   <!DOCTYPE html>
   <html>
   <head>
     <style>
       body { font-family: Arial, sans-serif; background: #0A0500; color: #FFF; }
       .container { max-width: 600px; margin: 0 auto; padding: 20px; }
       .header { border-bottom: 2px solid #FF5C01; padding-bottom: 10px; }
       .button { 
         background: #FF5C01;
         color: #0A0500;
         padding: 12px 24px;
         text-decoration: none;
         border-radius: 4px;
         display: inline-block;
         font-weight: bold;
       }
     </style>
   </head>
   <body>
     <div class="container">
       <div class="header">
         <h2>Welcome to %APP_NAME%!</h2>
       </div>
       
       <p>Hello %DISPLAY_NAME%,</p>
       
       <p>Thank you for signing up! Please verify your email address to unlock all features.</p>
       
       <p><a href="%LINK%" class="button">Verify Email Address</a></p>
       
       <p>Or copy and paste this link:</p>
       <p style="word-break: break-all; background: #1a1a1a; padding: 10px; border-radius: 4px;">
         %LINK%
       </p>
       
       <p>If you didn't sign up for this account, you can safely ignore this email.</p>
       
       <p>
         Questions? <a href="https://ngoding-lok.web.app/help" style="color: #FF5C01;">Visit our help center</a>
       </p>
       
       <hr style="border: none; border-top: 1px solid #FF5C01; margin: 20px 0;">
       
       <p style="font-size: 12px; color: #999;">
         <strong>%APP_NAME%</strong><br>
         Learn to code through games<br>
         <a href="https://ngoding-lok.web.app" style="color: #FF5C01;">ngoding-lok.web.app</a>
       </p>
     </div>
   </body>
   </html>
   ```

4. Set **Sender Name**: `Ngoding Lok`
5. Set **Reply-To** (optional): `support@ngoding-lok.com`
6. Click **Save**

---

## 3. Password Reset Template

### Customize Password Reset Email

1. Click **Password Reset** template
2. Edit **Subject**:
   ```
   Reset your %APP_NAME% password
   ```

3. Edit **Message** (similar HTML structure):
   ```html
   <p>Hello %DISPLAY_NAME%,</p>
   
   <p>We received a request to reset the password for your %APP_NAME% account.</p>
   
   <p><a href="%LINK%" class="button">Reset Password</a></p>
   
   <p>This link expires in 1 hour.</p>
   
   <p>If you didn't request a password reset, you can ignore this email.</p>
   ```

---

## 4. Email Change Template

### Customize Email Change Confirmation

1. Click **Email Address Change** template
2. Edit **Subject**:
   ```
   Confirm your new email for %APP_NAME%
   ```

3. Include clear warning:
   ```html
   <p>Hello %DISPLAY_NAME%,</p>
   
   <p>We received a request to change the email address associated with your account.</p>
   
   <p><a href="%LINK%" class="button">Confirm Email Change</a></p>
   
   <p style="color: #FF5C01;">
     <strong>⚠️ Important:</strong> This link is only valid for 24 hours.
   </p>
   ```

---

## 5. MFA Enrollment Notification

### Customize MFA Email

1. Click **Multi-Factor Authentication Enrollment** template
2. Use as **purely informational** (no action needed)

   ```html
   <p>Hello %DISPLAY_NAME%,</p>
   
   <p style="background: #1a1a1a; border-left: 3px solid #FF5C01; padding: 10px;">
     <strong>Multi-Factor Authentication (MFA) Enabled</strong><br>
     Your account is now protected with SMS verification.
   </p>
   
   <p>When you sign in, you'll be asked to enter a verification code sent to your phone.</p>
   
   <p><strong>If you didn't enable MFA:</strong></p>
   <ul>
     <li>Your account may have been compromised</li>
     <li>Go to Settings → Security immediately</li>
     <li>Disable MFA and change your password</li>
   </ul>
   
   <p><a href="https://ngoding-lok.web.app/settings/security" class="button">Go to Settings</a></p>
   ```

---

## 6. Testing Email Templates

### Test Email Verification

1. Sign up with a real email address in the app
2. Check your inbox for verification email
3. Verify the styling, branding, and links work
4. Click the link and confirm verification state updates

### Test Password Reset

1. Go to sign-in screen
2. Click "Forgot Password"
3. Enter email address
4. Check inbox for reset email
5. Click link and reset password

### Manual Testing via Firebase Console

1. Go to **Authentication → Users**
2. Click on a user
3. Click **⋮ (three dots)** → **Send email address verification**
4. Email will be sent immediately

---

## 7. Email Template Variables

Firebase provides these variables in all templates:

| Variable | Description | Example |
|----------|-------------|---------|
| `%APP_NAME%` | Your app name | "Ngoding Lok" |
| `%DISPLAY_NAME%` | User's display name | "Raynold Kabai" |
| `%NEW_EMAIL%` | New email (email change only) | "new@example.com" |
| `%LINK%` | Action link (auto-generated) | `https://.../__/auth/action?...` |

---

## 8. Email Verification in App Code

### Current Implementation

Email verification is already implemented in the app:

```dart
// In email_auth_service.dart - Line 32-34
if (user != null && !user.emailVerified) {
  await user.sendEmailVerification();
}
```

### Check Verification Status

```dart
// In settings_screen.dart and profile_screen.dart
bool isVerified = EmailAuthService.emailVerified;
```

### Resend Verification Email

```dart
// User can manually resend via Settings
await EmailAuthService.sendEmailVerification();
```

### Email Verification Banner

Added `EmailVerificationBanner` widget to prompt unverified users:

```dart
// In home_dashboard_screen.dart or root_orchestrator.dart
EmailVerificationBanner(
  userEmail: user.email,
  onVerified: () {
    setState(() => _user = _user?.copyWith(...));
  },
)
```

---

## 9. Firebase Authentication Rules

### Secure Email Verification

Add custom claims to users who verify their email:

**Via Firebase Admin SDK (Cloud Functions):**

```javascript
// functions/src/index.ts
exports.verifyEmailTrigger = functions.auth.user().onCreate(async (user) => {
  // Set custom claim when email verified
  if (user.emailVerified) {
    await admin.auth().setCustomUserClaims(user.uid, {
      emailVerified: true,
      verifiedAt: new Date().toISOString(),
    });
  }
});
```

### Firestore Security Rules

```
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
  
  // Email verification required for sensitive operations
  match /settings {
    allow write: if request.auth.token.emailVerified == true;
  }
}
```

---

## 10. Best Practices

### ✅ DO:

- ✅ Customize email templates with brand colors (#FF5C01 orange, #0A0500 dark)
- ✅ Include clear call-to-action button
- ✅ Add company logo and branding
- ✅ Provide link to help/support for questions
- ✅ Use HTML templates for professional styling
- ✅ Set appropriate link expiration times
- ✅ Test all email flows before deployment
- ✅ Monitor email delivery in Firebase Analytics
- ✅ Add unsubscribe links for compliance (if applicable)

### ❌ DON'T:

- ❌ Ask users to copy-paste long links (use HTML buttons)
- ❌ Send unnecessary emails (avoid duplicate resends)
- ❌ Use generic sender names (use "Ngoding Lok" not "noreply")
- ❌ Change templates frequently (causes confusion)
- ❌ Forget to test on mobile email clients
- ❌ Skip branding customization (looks unprofessional)
- ❌ Set very short link expiration times (< 24 hours for email change)

---

## 11. Troubleshooting

### Email Not Arriving

**Problem:** User doesn't receive verification email

**Solutions:**
1. Check spam/junk folder
2. Verify email address is correct (typo?)
3. Check Firebase project quota (Gmail may rate limit)
4. Resend email via "Resend" button (60 second cooldown)
5. Check Firebase Console → Authentication → Logs

### Link Expired

**Problem:** User clicks link after expiration

**Solution:**
- Email links valid for 24 hours (default)
- User can request new verification email
- Implement resend workflow in app (already done)

### Customization Not Showing

**Problem:** Changes to template don't appear in emails

**Solutions:**
1. Clear browser cache and refresh
2. Wait 5-10 minutes for changes to propagate
3. Use private/incognito window for fresh load
4. Check that template language is set correctly

### Firebase Region Limits

**Problem:** Emails not sending in certain regions

**Solution:**
- Firebase email service available in most regions
- Check [Firebase docs](https://firebase.google.com/docs/projects/locations) for regional availability

---

## 12. Monitoring & Analytics

### Monitor Email Sending

1. Go to **Firebase Console → Analytics**
2. Create event for email verification:
   ```
   Event: email_verification_sent
   Parameters: user_id, timestamp
   ```

3. Track verification completion:
   ```
   Event: email_verified
   Parameters: user_id, verification_time_seconds
   ```

### View Email Delivery Logs

1. Go to **Authentication → Logs**
2. Filter by "Email sent" events
3. View success/failure rates

---

## 13. Security Considerations

### Prevent Email Enumeration

Firebase automatically prevents email enumeration (disclosing whether an email is registered):
- "User not found" error returns generic message
- Implemented in `email_auth_service.dart` line 85

### Protect Email Links

- Links are time-limited (24 hours default)
- Links are single-use
- Links require correct user context

### Track Suspicious Activity

1. Set up Cloud Functions to monitor:
   - Multiple failed verification attempts
   - Verification requests from different IPs
   - Email change requests to suspicious addresses

2. Implement rate limiting:
   - Max 5 verification resends per hour
   - 1-minute cooldown between resends

---

## Conclusion

Email templates are fully configured in Firebase and ready to use. Users will:
1. ✅ Receive verification email on signup
2. ✅ Be able to resend if not received
3. ✅ See in-app banner prompting verification
4. ✅ Unlock MFA after email verified
5. ✅ Receive password reset emails
6. ✅ Get confirmation on email change

**Status:** ✅ Ready for production

For questions, check Firebase docs: https://firebase.google.com/docs/auth/custom-email-handler
