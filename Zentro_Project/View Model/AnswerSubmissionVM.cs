namespace zentro.View_Model
{
    public class AnswerSubmissionVM
    {
        public int QuestionId { get; set; }
        public int? SelectedOptionId { get; set; }   // For radio, dropdown, single-select
        public List<int> SelectedOptionIds { get; set; } = new(); // For checkboxes
        public string AnswerText { get; set; }       // For input fields
        public int AnswerInput { get; set; }
        public List<TableLineItemVM> LineItems { get; set; } = new(); // For table
    }

    public class TableLineItemVM
    {
        public int? OptionId { get; set; }
        public int Quantity { get; set; }
    }
}
