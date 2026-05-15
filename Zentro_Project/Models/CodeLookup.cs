using System;
using System.Collections.Generic;

namespace zentro.Models;

public partial class CodeLookup
{
    public string CodeName { get; set; } = null!;

    public int CodeEnum { get; set; }

    public string? CodeText { get; set; }
}
