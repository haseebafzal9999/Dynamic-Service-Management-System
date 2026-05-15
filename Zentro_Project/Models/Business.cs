using System;
using System.Collections.Generic;

namespace zentro.Models;

public partial class Business
{
    public int BusinessId { get; set; }

    public string Name { get; set; } = null!;

    public string? PhoneNumber { get; set; }

    public string? Email { get; set; }

    public string? AddressFirstLine { get; set; }

    public string? CityTown { get; set; }

    public string? Postcode { get; set; }

    public string? Country { get; set; }

    public string? Currency { get; set; }

    public string? CurrencyIdentity { get; set; }
}
