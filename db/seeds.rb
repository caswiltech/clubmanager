# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
rchfc = Club.create(:long_name => "Royal City Hyacks Football Club",
  :short_name => "RCHFC",
  :subdomain => "rchfc",
  :contact_email => "info@hyackfootball.com",
  :reg_notify_email => "info@hyackfootball.com",
  :street1 => "PO Box 257 - 720 6th Street",
  :city => "New Westminster",
  :province => "BC",
  :country => "Canada",
  :postalcode => "V3L3C5",
  :phone => "604-868-7926",
  :homepage_url => "http://www.hyackfootball.com/rchfc/"
)
spring = Season.create(
  :club => rchfc,
  :name => "2011 Spring Flag",
  :default => false,
  :start_season_on => Date.civil(2011,1,1),
  :end_season_on => Date.civil(2011,12,31),
  :start_reg_on => Date.civil(2011,3,1),
  :end_reg_on => Date.civil(2011,4,30)
)
summer = Season.create(
  :club => rchfc,
  :name => "2011 Summer/Fall Football",
  :default => true,
  :start_season_on => Date.civil(2011,1,1),
  :end_season_on => Date.civil(2011,12,31),
  :start_reg_on => Date.civil(2011,3,1),
  :end_reg_on => Date.civil(2011,9,30)
)
cheer = Season.create(
  :club => rchfc,
  :name => "2011 Cheerleading",
  :default => false,
  :start_season_on => Date.civil(2011,1,1),
  :end_season_on => Date.civil(2011,12,31),
  :start_reg_on => Date.civil(2011,3,1),
  :end_reg_on => Date.civil(2011,9,30)
)
u12 = Division.create(
  :club => rchfc,
  :name => "U12 Spring Flag",
  :minimum_age => 9,
  :maximum_age => 11
)
u14 = Division.create(
  :club => rchfc,
  :name => "U14 Spring Flag",
  :minimum_age => 12,
  :maximum_age => 13
)
u16 = Division.create(
  :club => rchfc,
  :name => "U16 Spring Flag",
  :minimum_age => 14,
  :maximum_age => 15
)
flag = Division.create(
  :club => rchfc,
  :name => "Flag",
  :minimum_age => 5,
  :maximum_age => 7
)
atom = Division.create(
  :club => rchfc,
  :name => "Atom",
  :minimum_age => 8,
  :maximum_age => 9
)
peewee = Division.create(
  :club => rchfc,
  :name => "Peewee",
  :minimum_age => 10,
  :maximum_age => 11
)
jb = Division.create(
  :club => rchfc,
  :name => "Junior Bantam",
  :minimum_age => 12,
  :maximum_age => 13
)
cheeratom = Division.create(
  :club => rchfc,
  :name => "Atom",
  :minimum_age => 6,
  :maximum_age => 9
)
cheerpw = Division.create(
  :club => rchfc,
  :name => "Peewee",
  :minimum_age => 10,
  :maximum_age => 12
)
springsd = SeasonDivision.create(
  :season => spring,
  :division => u12
)
springsd = SeasonDivision.create(
  :season => spring,
  :division => u14
)
springsd = SeasonDivision.create(
  :season => spring,
  :division => u16,
  :hidden => true
)
summersd = SeasonDivision.create(
  :season => summer,
  :division => flag
)
summersd = SeasonDivision.create(
  :season => summer,
  :division => atom
)
summersd = SeasonDivision.create(
  :season => summer,
  :division => peewee
)
summersd = SeasonDivision.create(
  :season => summer,
  :division => jb
)
summersd = SeasonDivision.create(
  :season => cheer,
  :division => cheeratom
)
summersd = SeasonDivision.create(
  :season => cheer,
  :division => cheerpw
)
role = PersonRole.create(
  :club => rchfc,
  :role_name => "Parent/Guardion",
  :role_abbreviation => "PG"
)
role = PersonRole.create(
  :club => rchfc,
  :role_name => "Emergency Contact",
  :role_abbreviation => "EC"
)