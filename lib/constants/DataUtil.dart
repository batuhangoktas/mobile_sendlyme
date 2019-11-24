class DataUtil
{
  var types = {"doc":"doc.png", "jpg":"jpg.png", "jpg":"jpg.png", "unknown":"unknown.png", "txt":"txt.png", "xls":"xls.png"
    , "png":"png.png", "mp4":"mp4.png", "mp3":"mp3.png", "jpeg":"jpg.png", "xlsx":"xls.png", "pdf":"pdf.png","docx":"doc.png"};
  getLogoByType(String fileName){
    int pointLocation = fileName.lastIndexOf(".");
    if(pointLocation>0)
      {
        String extension = fileName.substring(pointLocation+1,fileName.length);
        if(types[extension]!=null)
          return types[extension];
        else
          return types["unknown"];
      }
    else
      {
        return types["unknown"];
      }

  }


}