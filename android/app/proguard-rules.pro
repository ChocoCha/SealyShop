# Keep rules for Stripe and Google dependencies
-keep class com.stripe.** { *; }
-keep class com.google.android.gms.wallet.** { *; }
-keep class com.google.android.gms.identity.** { *; }
-keep class com.stripe.android.pushProvisioning.** { *; }

# Added -dontwarn rules suggested by R8 (see build outputs/mapping/release/missing_rules.txt)
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider