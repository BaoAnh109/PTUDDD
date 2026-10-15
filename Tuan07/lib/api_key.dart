/// API Key dùng chung cho Google Maps (bản đồ), Directions API,
/// Geocoding API và Places API.
///
/// Cách lấy key (theo đề bài):
/// 1. Vào Google Cloud Console (console.cloud.google.com), tạo project mới.
/// 2. APIs & Services > Library: bật "Maps SDK for Android",
///    "Directions API", "Geocoding API", "Places API".
/// 3. APIs & Services > Credentials > Create Credentials > API Key.
///
/// Ngoài ra phải khai báo key trong Android:
///   android/app/src/main/AndroidManifest.xml
///   <meta-data android:name="com.google.android.geo.API_KEY"
///              android:value="KEY_CUA_BAN"/>
const String googleMapsApiKey = 'YOUR_API_KEY_HERE';
