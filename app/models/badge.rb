# class Badge
# def give_badge
# # gen badge
#   assert_url = HTTParty.post("http://playbadges.tsl.ac.uk/api",
#     :headers => { "recipient" => current_user.email, "evidence" => "http://www.example.org", "badgeId" => "1"},
#     :basic_auth => {:username => "martin.page@tsl.ac.uk", :password => "B0nF1rE"})
#  # redirect to receive badge
# end


#IDEAS :




# bob = User.new()

#bob creates a new experiment:

# scorecard = Scorecard.where().eq(user, bob.id).eq(badge, BadgeController.EXPERIMENT_BADGE)

# if scorecard
#   if scorecard.complete
#     break # they do not need this badge, they aready have it
#   else
#     scorecard.points +=1
#     if scorecard.complete
#       awardBadge()
#     end
#   end
# else

#   Scorecard.new(user = bob.id, badge = BadgeController.EXPERIMENT_BADGE, points = 1)

#   if scorecard.complete
#     awardBadge()
#   end


# end








#just to avoid comp errors

# class Scorecard

# end

# def awardBadge()

# end

# class User

# end

# class BadgeController
#   @@EXPERIMENT_BADGE = 5
# end