import re

with open('lib/features/auth/presentation/screens/login_screen.dart', 'r') as f:
    content = f.read()

# I want to insert the button after the TextButton.icon and before the Center(child: Text.rich
# The text button ends with `),`
# Let's find the useEmail label and then the `Center(`

pattern = r'''(label:\s*Text\(\s*_isEmailLogin \? l10n\.usePhone : l10n\.useEmail,\s*style:\s*TextStyle\(\s*fontWeight:\s*FontWeight\.w800,\s*color:\s*context\.secondaryTextColor,\s*fontSize:\s*12\.sp,\s*\),\s*\),\s*\),\s*child:\s*Text\.rich\()'''

replacement = r'''label: Text(
                            _isEmailLogin ? l10n.usePhone : l10n.useEmail,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: context.secondaryTextColor,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Center(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _onGoogleSignIn,
                            icon: Icon(
                              LucideIcons.chrome,
                              size: 14.w,
                              color: Colors.red,
                            ),
                            label: Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: context.primaryTextColor,
                                fontSize: 12.sp,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.w),
                              ),
                              side: BorderSide(color: context.borderColor),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Center(
                        child: Text.rich('''

new_content = re.sub(r'label:\s*Text\(\s*_isEmailLogin \? l10n\.usePhone : l10n\.useEmail,\s*style:\s*TextStyle\(\s*fontWeight:\s*FontWeight\.w800,\s*color:\s*context\.secondaryTextColor,\s*fontSize:\s*12\.sp,\s*\),\s*\),\s*child:\s*Text\.rich\(', replacement, content)

with open('lib/features/auth/presentation/screens/login_screen.dart', 'w') as f:
    f.write(new_content)
