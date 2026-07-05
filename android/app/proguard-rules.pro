-keep class io.flutter.** { *; }
-keep class com.iammaking.post.** { *; }

# Flutter references Play Core for deferred components; we don't use them
# but R8 still needs to resolve the references — suppress the warnings.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
