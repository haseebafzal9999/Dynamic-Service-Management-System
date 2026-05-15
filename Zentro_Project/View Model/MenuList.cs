namespace zentro.View_Model
{
    public class MenuList
    {
        public string optionName { get; set; }
        public string optionSVG { get; set; }
        public string optionLink { get; set; }
        public List<ChildrenValues> children { get; set; }
        public string pageName { get; set; }
        public int position { get; set; }

    }

    public class ChildrenValues
    {
        public string Name { get; set; }
        public string Link { get; set; }
    }
}
