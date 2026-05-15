using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using NuGet.Versioning;
using System;
using System.IO;
using System.Security.Cryptography;
using zentro.Areas.Identity.Data;
using zentro.Models;
using zentro.View_Model;

namespace zentro.library
{
    public static class Common
    {

        public enum InvoiceStatus
        {
            Draft = 0,          // Invoice created but not sent
            Sent = 1,           // Invoice sent to customer
            PartiallyPaid = 2,  // Part of the invoice has been paid
            Paid = 3,           // Invoice fully paid
            Overdue = 4,        // Past due date, not fully paid
            Cancelled = 5,      // Invoice voided or cancelled
            Refunded = 6,       // Invoice refunded or credit issued
            Disputed = 7        // Customer has disputed the invoice
        }

        public static int GetUserBusinessId(dbContext context, string stringUserName)
        {
            var user = context.Users.Where(x => x.Id == stringUserName);

            if (user == null)
            {
                return 0;
            }

            int businessId = user.Select(x => x.BusinessId).FirstOrDefault();

            return businessId;
        }

        public static int GetUserId(dbContext context, string stringUserName)
        {
            var user = context.Users.Where(x => x.Id == stringUserName);

            if (user == null)
            {
                return 0;
            }

            int userId = user.Select(x => x.UserId).FirstOrDefault();

            return userId;
        }

        public static string DecodeUrlString(string url)
        {
            string newUrl;
            while ((newUrl = Uri.UnescapeDataString(url)) != url)
                url = newUrl;
            return newUrl;
        }

        public static int GetUserBusinessId(dbContext context, int userId)
        {
            var user = context.Users.Where(x => x.UserId == userId);

            if (user == null)
            {
                return 0;
            }

            int businessId = user.Select(x => x.BusinessId).FirstOrDefault();

            return businessId;
        }

        public static string GetUserName(dbContext context, int userId)
        {
            var user = context.Users.Where(x => x.UserId == userId).FirstOrDefault();

            if (user == null)
            {
                return "";
            }

            string firstName = user.FirstName;
            string lastName = user.LastName;

            return firstName + " " + lastName;
        }

        public static DateOnly? ParseStringToDateOnly(string strDate)
        {
            if (!DateTime.TryParse(strDate, out DateTime formattedDate))
            {
                return null;
            }

            return DateOnly.FromDateTime(formattedDate);
        }

        public static string SaveImage(string image, string filePath)
        {
            if (image != "0")
            {
                // Assuming 'customerImage' contains the full Base64 string
                string base64Data = image.Split(',')[1];

                // Decode Base64 string to byte array
                byte[] imageBytes = Convert.FromBase64String(base64Data);

                string randomFileName;
                string fullFilePath;

                Directory.CreateDirectory(filePath);

                randomFileName = string.Format("{0}.jpg", Path.GetRandomFileName());
                fullFilePath = Path.Combine(filePath, randomFileName);

                //do
                //{
                //    // Define the name for the image
                //    randomFileName = string.Format("{0}.jpg", Path.GetRandomFileName());

                //    // Define the full file path
                //    fullFilePath = Path.Combine(filePath, randomFileName);

                //    // Checking if the file name already exists
                //} while (File.Exists(fullFilePath));

                // Using async/await to handle file writing asynchronously
                using (var stream = new FileStream(fullFilePath, FileMode.Create))
                {
                    using (var memoryStream = new MemoryStream(imageBytes))
                    {
                        memoryStream.CopyTo(stream);
                    }
                }

                // Return the random file name to save in the customer's record
                return string.Format("\\{0}", randomFileName);
            }

            // Return null or empty string if no image is provided
            return null;
        }

        public static async Task<UserModel> UserInfo(UserManager<ApplicationUser> _userManager, string userEmail)
        {
            UserModel model = new UserModel();
            var user = await _userManager.FindByEmailAsync(userEmail);

            //set the user name
            model.Name = $"{user.FirstName} {user.LastName}";

            //set the user email
            model.Email = user.Email;

            //set the user initials
            model.Initials = user.FirstName[0].ToString() + user.LastName[0].ToString();

            //set the user id
            model.UserId = user.UserId;

            return model;
        }


        private static string GeneratePatternedAlphanumeric(Random random)
        {
            const string letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            const string digits = "0123456789";

            char RandomLetter() => letters[random.Next(letters.Length)];
            char RandomDigit() => digits[random.Next(digits.Length)];

            return string.Concat(
                RandomLetter(), RandomLetter(),
                RandomDigit(), RandomDigit(),
                RandomLetter(), RandomLetter(),
                RandomDigit(), RandomDigit(),
                RandomLetter(), RandomLetter()
            );
        }

        public static string GenerateRandomDigits(int length)
        {
            var bytes = new byte[length];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(bytes);
            }

            var digits = bytes.Select(b => (b % 10).ToString());
            return string.Concat(digits);
        }

        public static async Task<FileModel> FileUpload(string filePath, IFormFile file, bool requiredDateFolders)
        {
            DateTime currentDateTime = DateTime.Now;

            string path = filePath;
            string shortPath = "";

            if (requiredDateFolders)
            {
                string dateDay = currentDateTime.ToString("dd");
                string dateMonth = currentDateTime.ToString("MM");
                string dateYear = currentDateTime.Year.ToString();
                shortPath = Path.Combine(dateYear, dateMonth, dateDay);
                path = Path.Combine(filePath, shortPath);
            }

            // checks the directory  and creates exists
            Directory.CreateDirectory(path);

            string extension = Path.GetExtension(file.FileName);
            string randomName = $"{Path.GetFileNameWithoutExtension(Path.GetRandomFileName())}{extension}";
            string uploadShortPath = Path.Combine(shortPath, randomName);
            string uploadPath = Path.Combine(path, randomName);

            // Save the file asynchronously
            using (var stream = System.IO.File.Create(uploadPath))
            {
                await file.CopyToAsync(stream);
            }

            long fileSize = new FileInfo(uploadPath).Length;

            return new FileModel
            {
                FileName = Path.GetFileNameWithoutExtension(file.FileName),
                FileStorageName = randomName,
                FilePath = uploadShortPath,
                FileSize = (int)fileSize,
                FileType = extension
            };
        }

        public static string GetMimeType(string filePath)
        {
            var provider = new Microsoft.AspNetCore.StaticFiles.FileExtensionContentTypeProvider();
            if (!provider.TryGetContentType(filePath, out string contentType))
            {
                contentType = "application/octet-stream"; // Default fallback
            }
            return contentType;
        }

        public static bool RemoveFile(string filePath)
        {
            if (System.IO.File.Exists(filePath))
            {
                try
                {
                    System.IO.File.Delete(filePath);
                    return true;
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error deleting file: {ex.Message}");
                    return false;
                }
            }

            // Return false if the file does not exist
            return false;
        }


        public static void ConcurrencyCheck(uint currentXmin, uint dbXmin)
        {
            if (currentXmin != dbXmin)
            {
                throw new Exception("Concurrency conflict - please refresh the page an try again.");
            }
        }

        public static void BusinessCheck(int userBusinessId, int objectBusinessId)
        {
            if (userBusinessId != objectBusinessId)
            {
                throw new Exception("Business conflict - this is unaccessible.");
            }
        }


    }
}
