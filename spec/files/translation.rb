table "users" do
  column "id", :key
  column "first_name", :string
  column "last_name", :string
  column "created_at", :datetime
  column "updated_at", :datetime
end

table "posts" do
  column "id", :key
  column "title", :string
  column "owner_id", :integer, :references => "users", :rename_to => 'user_id'
  column "body", :text
  column "published_at", :datetime
  column "created_at", :datetime
  column "updated_at", :datetime
end

table "comments", :embed_in => 'posts', :on => 'post_id' do
  column "id", :key
  column "body", :text
  column "post_id", :integer, :references => "posts"
  column "user_id", :integer, :references => "users"
  column "created_at", :datetime
  column "updated_at", :datetime
end

table "preferences", :embed_in => 'users', :as => 'object' do
  column "id", :key
  column "user_id", :integer, :references => "users"
  column "notify_by_email", :boolean
  column "created_at", :datetime, :ignore => true
  column "updated_at", :datetime, :ignore => true
end

table "notes", :polymorphic => 'notable', :embed_in => true do
  column "id", :key
  column "user_id", :integer, :references => "users"
  column "notable_id", :integer, :references => "notables"
  column "notable_type", :string
  column "body", :text
  column "created_at", :datetime
  column "updated_at", :datetime
end