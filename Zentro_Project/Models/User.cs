using System;
using System.Collections.Generic;

namespace zentro.Models;

public partial class User
{
    public string Id { get; set; } = null!;

    public int BusinessId { get; set; }

    public int UserId { get; set; }

    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public string? UserName { get; set; }

    public string? NormalizedUserName { get; set; }

    public string? Email { get; set; }

    public string? NormalizedEmail { get; set; }

    public bool EmailConfirmed { get; set; }

    public string? PasswordHash { get; set; }

    public string? SecurityStamp { get; set; }

    public string? ConcurrencyStamp { get; set; }

    public string? PhoneNumber { get; set; }

    public bool PhoneNumberConfirmed { get; set; }

    public bool TwoFactorEnabled { get; set; }

    public DateTime? LockoutEnd { get; set; }

    public bool LockoutEnabled { get; set; }

    public int AccessFailedCount { get; set; }

    public virtual ICollection<DependentQuestion> DependentQuestionCreatedBies { get; set; } = new List<DependentQuestion>();

    public virtual ICollection<DependentQuestion> DependentQuestionModifiedBies { get; set; } = new List<DependentQuestion>();

    public virtual ICollection<FieldType> FieldTypeCreatedBies { get; set; } = new List<FieldType>();

    public virtual ICollection<FieldType> FieldTypeModifiedBies { get; set; } = new List<FieldType>();

    public virtual ICollection<MiscLookup> MiscLookupCreatedBies { get; set; } = new List<MiscLookup>();

    public virtual ICollection<MiscLookup> MiscLookupModifiedBies { get; set; } = new List<MiscLookup>();

    public virtual ICollection<Question> QuestionCreatedBies { get; set; } = new List<Question>();

    public virtual ICollection<QuestionGroup> QuestionGroupCreatedBies { get; set; } = new List<QuestionGroup>();

    public virtual ICollection<QuestionGroup> QuestionGroupModifiedBies { get; set; } = new List<QuestionGroup>();

    public virtual ICollection<Question> QuestionModifiedBies { get; set; } = new List<Question>();

    public virtual ICollection<QuestionOption> QuestionOptionCreatedBies { get; set; } = new List<QuestionOption>();

    public virtual ICollection<QuestionOption> QuestionOptionModifiedBies { get; set; } = new List<QuestionOption>();

    public virtual ICollection<Template> TemplateCreatedBies { get; set; } = new List<Template>();

    public virtual ICollection<Template> TemplateModifiedBies { get; set; } = new List<Template>();

    public virtual ICollection<TemplateVersion> TemplateVersionCreatedBies { get; set; } = new List<TemplateVersion>();

    public virtual ICollection<TemplateVersion> TemplateVersionModifiedBies { get; set; } = new List<TemplateVersion>();

    public virtual ICollection<UserAnswer> UserAnswerCreatedBies { get; set; } = new List<UserAnswer>();

    public virtual ICollection<UserAnswer> UserAnswerModifiedBies { get; set; } = new List<UserAnswer>();

    public virtual ICollection<UserClaim> UserClaims { get; set; } = new List<UserClaim>();

    public virtual ICollection<UserLogin> UserLogins { get; set; } = new List<UserLogin>();

    public virtual ICollection<UserRecord1> UserRecord1CreatedBies { get; set; } = new List<UserRecord1>();

    public virtual ICollection<UserRecord1> UserRecord1ModifiedBies { get; set; } = new List<UserRecord1>();

    public virtual ICollection<UserToken> UserTokens { get; set; } = new List<UserToken>();

    public virtual ICollection<Role> Roles { get; set; } = new List<Role>();
}
