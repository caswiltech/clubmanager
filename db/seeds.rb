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
  :postal_code => "V3L3C5",
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
  :name => "Flag Football",
  :minimum_age => 5,
  :maximum_age => 7
)
atom = Division.create(
  :club => rchfc,
  :name => "Atom Football",
  :minimum_age => 8,
  :maximum_age => 9
)
peewee = Division.create(
  :club => rchfc,
  :name => "Peewee Football",
  :minimum_age => 10,
  :maximum_age => 11
)
jb = Division.create(
  :club => rchfc,
  :name => "Junior Bantam Football",
  :minimum_age => 12,
  :maximum_age => 13
)
cheer_div = Division.create(
  :club => rchfc,
  :name => "Junior Cheerleading",
  :minimum_age => 6,
  :maximum_age => 13
)
springsdu12 = SeasonDivision.create(
  :season => spring,
  :division => u12
)
springsdu14 = SeasonDivision.create(
  :season => spring,
  :division => u14
)
springsdu16 = SeasonDivision.create(
  :season => spring,
  :division => u16,
  :hidden => true
)
summersdflag = SeasonDivision.create(
  :season => summer,
  :division => flag
)
summersdatom = SeasonDivision.create(
  :season => summer,
  :division => atom
)
summersdpeewee = SeasonDivision.create(
  :season => summer,
  :division => peewee
)
summersdjb = SeasonDivision.create(
  :season => summer,
  :division => jb
)
cheersd = SeasonDivision.create(
  :season => cheer,
  :division => cheer_div
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
pp = PaymentPackage.create(
  :club => rchfc,
  :season_division => springsdu12,
  :name => "U12 Spring Flag 2011",
  :amount => 100.00
)
pp = PaymentPackage.create(
  :club => rchfc,
  :season_division => springsdu14,
  :name => "U14 Spring Flag 2011",
  :amount => 100.00
)
pp = PaymentPackage.create(
  :club => rchfc,
  :season_division => springsdu16,
  :name => "U16 Spring Flag 2011",
  :amount => 100.00
)
pp = PaymentPackage.create(
  :club => rchfc,
  :season_division => summersdflag,
  :name => "Flag 2011",
  :amount => 100.00
)
pp = PaymentPackage.create(
  :club => rchfc,
  :season_division => summersdatom,
  :name => "Atom 2011",
  :amount => 150.00
)
pp = PaymentPackage.create(
  :club => rchfc,
  :season_division => summersdpeewee,
  :name => "Peewee 2011",
  :amount => 200.00
)
pp = PaymentPackage.create(
  :club => rchfc,
  :season_division => summersdjb,
  :name => "Junior Bantam 2011",
  :amount => 250.00
)
pp = PaymentPackage.create(
  :club => rchfc,
  :season_division => cheersd,
  :name => "Junior Cheerleading 2011",
  :amount => 150.00
)