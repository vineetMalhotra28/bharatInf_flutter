// const String BaseUrl = "https://ad31-2401-4900-1c6e-fb71-7162-89da-2626-df91.in.ngrok.io/";
import 'package:flutter_dotenv/flutter_dotenv.dart';

String BaseUrl = dotenv.get("API_URL");

String Login_api = BaseUrl + "api/auth/login";
String Logout_api = BaseUrl + "api/auth/logout";
String Language_api = BaseUrl + "api/auth/showPageData";
String UserHome_api = BaseUrl + "api/getHomeData?limit=20&pageNo=0";
String confirm_api = BaseUrl + "api/confirmAndDeleteAppointment";
String showAvailableSlots_api = BaseUrl + "api/showAvailableSlots";
String rescheduleMeeting_api = BaseUrl + "api/rescheduleMeeting";
String set_user_language_api = BaseUrl + "api/setUserLanguage";
String user_notifications_api =
    BaseUrl + "api/getUserNotification?limit=20&pageNo=0";
String getUserNotificationCount = BaseUrl + "api/getUserNotificationCount";
String readAndDeleteNotification = BaseUrl + "api/readAndDeleteNotification";
String changeUserSettings = BaseUrl + "api/changeUserSettings";
String getUserProfile = BaseUrl + "api/getUserProfile";
