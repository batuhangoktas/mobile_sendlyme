
class GetConstants
{
  static String hostAdress = "";
  static String hostSeperation = ":";
  static String hostPrefix = "https://";

  static String createSessionService = "/sendlyme/session/createsession";
  static String joinSessionService = "/sendlyme/session/joinsession";
  static String hasSessionSyncService = "/sendlyme/session/hassessionsync";
  static String downloadService = "/sendlyme/session/download";
  static String tookFileService = "/sendlyme/session/tookfile";
  static String uploadService = "/sendlyme/session/upload";
  static String finishSessionService = "/sendlyme/session/finishsession";

  static String getService()
  {
    return hostPrefix + hostAdress;
  }
  static String getCreateSessionService()
  {
    return getService().toString()+createSessionService;
  }
  static String getJoinSessionService()
  {
    return getService().toString()+joinSessionService;
  }
  static String getHasSessionSyncService()
  {
    return getService().toString()+hasSessionSyncService;
  }
  static String getDownloadService()
  {
    return getService().toString() + downloadService;
  }
  static String getTookFileService()
  {
    return getService().toString() + tookFileService;
  }
  static String getUploadService()
  {
    return getService().toString() + uploadService;
  }
  static String getFinishSessionService()
  {
    return getService().toString() + finishSessionService;
  }
}