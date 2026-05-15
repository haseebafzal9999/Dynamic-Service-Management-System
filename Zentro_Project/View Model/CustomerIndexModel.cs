namespace zentro.View_Model
{
    public class CustomerIndexModel
    {
        public int? CustomerId { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? Email { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Address { get; set; }
        public string? AppartmentSuite { get; set; }
        public string? City { get; set; }
        public string? PostalCode { get; set; }
        public string? Country { get; set; }
        public DateTime? CreatedAt { get; set; }
        public string? CreatedById { get; set; }
        public DateTime? ModifiedAt { get; set; }
        public string? ModifiedById { get; set; }
        public bool IsActive { get; set; }
        public bool IsDeleted { get; set; }
        public int? Id { get; set; }

    }
}
