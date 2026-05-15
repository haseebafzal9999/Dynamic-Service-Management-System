namespace zentro.View_Model
{
    public class ReadAppSettings
    {
        private readonly IConfiguration _configuration;
        public string filePath { get; set; }
        public string profileImgFilePath { get; set; }
        public string dlImgFilePath { get; set; }


        public ReadAppSettings(IConfiguration configuration)
        {
            this._configuration = configuration;
            this.filePath = _configuration["AppSettings:filePath"] ?? "File Path cannot be found";
            this.profileImgFilePath = _configuration["AppSettings:profileImgFilePath"] ?? "File Path cannot be found";
            this.dlImgFilePath = _configuration["AppSettings:dlImgfilePath"] ?? "File Path cannot be found";

        }

        public string GetFilePath()
        {
            return filePath;
        }

        public string GetProfileImgPath()
        {
            return profileImgFilePath;
        }

        public string GetDlImgPath()
        {
            return dlImgFilePath;
        }
    }
}
