using System.Security.Cryptography;
using System.Text;

namespace zentro.Infrastructure.Security
{
    public static class KeyGenerator
    {
        private const string AllowedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        private const int KeyLength = 64; // fixed length (must be even)

        public static string GenerateKey()
        {
            var result = new StringBuilder(KeyLength);
            var buffer = new byte[KeyLength];

            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(buffer);
            }

            for (int i = 0; i < KeyLength; i++)
            {
                result.Append(AllowedChars[buffer[i] % AllowedChars.Length]);
            }

            return result.ToString();
        }

        public static (string Part1, string Part2) SplitKey(string key)
        {
            if (string.IsNullOrEmpty(key))
                throw new ArgumentException("Key cannot be null or empty.");

            if (key.Length % 2 != 0)
                throw new ArgumentException("Key length must be even to split evenly.");

            int half = key.Length / 2;

            return (key.Substring(0, half), key.Substring(half));
        }

    }
}
