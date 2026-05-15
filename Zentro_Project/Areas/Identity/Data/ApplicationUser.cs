using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore.Metadata.Internal;

namespace zentro.Areas.Identity.Data;

// Add profile data for application users by adding properties to the ApplicationUser class
public class ApplicationUser : IdentityUser
{
    [PersonalData]
    [Column(TypeName = "integer")]
    public int BusinessId { get; set; }

    [PersonalData]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int UserId { get; set; }

    [PersonalData]
    [Column(TypeName = "text")]
    public string FirstName { get; set; }

    [PersonalData]
    [Column(TypeName = "text")]
    public string LastName { get; set; }
}

