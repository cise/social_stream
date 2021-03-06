class Group < ActiveRecord::Base
  attr_accessor :_founder
  attr_accessor :_participants
  attr_accessor :profile_attributes

  def followers
    subjects(:subject_type => :user, :direction => :senders)
  end

  after_create :create_founder
  after_create :create_participants
  
  def recent_groups
    subjects(:subject_type => :group, :direction => :receivers) do |q|
      q.select("ties.created_at").
        merge(Tie.recent)
    end
  end
 
  private

  #Creates the ties between the group and the founder
  def create_founder
    founder =
      Actor.find_by_permalink(_founder) || raise("Cannot create group without founder")

    sent_ties.create! :receiver => founder,
                      :relation => relations.sort.first
  end
  
  #Creates the ties betwbeen the group and the participants
  def create_participants
    
     return if @_participants.blank?
    
     @_participants.each do |participant|
      
      participant_actor = Actor.find_by_id(participant.to_i)

      sent_ties.create! :receiver => participant_actor,
                        :relation => relations.sort.first
     end
  end
end
