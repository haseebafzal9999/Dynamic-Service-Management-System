namespace zentro.Services.Group
{
    public interface IGroupService
    {
        public Task<GroupResponse> CreateOrUpdateGroupAsync(GroupRequest request);
        public Task<bool> DeleteGroupAsync(int groupId);
        Task<bool> DeleteGroupByGuidAsync(string groupGuid, int templateVersionId);
    }
}
