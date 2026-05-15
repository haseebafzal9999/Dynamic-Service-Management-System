using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace zentro.Models;

public partial class Customer
{
    public int CustomerId { get; set; }

    [Column("business_id")]
    public int? BusinessId { get; set; }

    [ForeignKey("BusinessId")]
    public Business? Business { get; set; }


    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public string? Email { get; set; }

    public string? PhoneNumber { get; set; }

    public string? Address { get; set; }

    public string? AppartmentSuite { get; set; }

    public string? City { get; set; }

    public string? Postalcode { get; set; }

    public string? Country { get; set; }

    public string? UserId { get; set; }
    public DateTime? CreatedAt { get; set; }

    public string? CreatedById { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? ModifiedById { get; set; }

    public bool? IsActive { get; set; }

    public bool? IsDeleted { get; set; }
}
