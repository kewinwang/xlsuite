#- XLsuite, an integrated CMS, CRM and ERP for medium businesses
#- Copyright 2005-2009 iXLd Media Inc.  See LICENSE for details.

class ProfileAddRequest < ProfileRequest
  
  def approve!
    ProfileAddRequest.transaction do
      self.to_party_and_profile!
      self.approved_at = Time.now
      self.save!
    end
  end
  
  def to_party_and_profile!
    @party = self.account.parties.new
    %w( first_name middle_name last_name company_name position honorific avatar_id tag_list).each do |column|
      @party.send(column+"=", self.send(column))
    end
    
    @party.created_by = @party.updated_by = @party.referred_by = self.created_by
    @party.save!
    
    if self.group_ids
      groups = self.account.groups.all(:conditions => ["id IN (?)", self.group_ids.split(",")])
      @party.groups = groups unless groups.empty?
    end
    
    self.copy_contact_routes_to_party!(@party)
    @profile = @party.to_new_profile
    @profile.info = self.info
    @profile.owner = self.created_by
    @profile.save!
    self.comments.each do |comment|
      comment.commentable = @profile
      comment.save!
    end
    self.update_attribute(:profile_id, @profile.reload.id)
    @party.update_attribute(:profile_id, @profile.id)
    @party.reload
    @party.copy_contact_routes_to_profile!
  end
end
