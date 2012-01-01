class RchfcSeeds < ActiveRecord::Migration
  def self.up
    rchfc = Club.first
    spring = Season.last
    summer = Season.create(
      :club => rchfc,
      :name => "2012 Summer/Fall Football",
      :default => false,
      :start_season_on => Date.civil(2012,1,1),
      :end_season_on => Date.civil(2012,12,31),
      :start_reg_on => Date.civil(2012,1,1),
      :end_reg_on => Date.civil(2012,9,18)
    )
    cheer = Season.create(
      :club => rchfc,
      :name => "2012 Cheerleading",
      :default => false,
      :start_season_on => Date.civil(2012,1,1),
      :end_season_on => Date.civil(2012,12,31),
      :start_reg_on => Date.civil(2012,1,1),
      :end_reg_on => Date.civil(2012,9,18)
    )
    u10 = Division.create(
      :club => rchfc,
      :name => "U10 Spring Flag",
      :minimum_age => 8,
      :maximum_age => 9
    )
    u12 = Division.find_by_name("U12 Spring Flag")
    u14 = Division.find_by_name("U14 Spring Flag")
    u16 = Division.find_by_name("U16 Spring Flag")

    springsdu10 = SeasonDivision.create(
      :season => spring,
      :division => u10
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
      :division => Division.find_by_name("Flag Football")
    )
    summersdatom = SeasonDivision.create(
      :season => summer,
      :division => Division.find_by_name("Atom Football")
    )
    summersdpeewee = SeasonDivision.create(
      :season => summer,
      :division => Division.find_by_name("Peewee Football")
    )
    summersdjb = SeasonDivision.create(
      :season => summer,
      :division => Division.find_by_name("Junior Bantam Football")
    )
    cheersd = SeasonDivision.create(
      :season => cheer,
      :division => Division.find_by_name("Junior Cheerleading")
    )
    pp = PaymentPackage.create(
      :club => rchfc,
      :season_division => springsdu10,
      :name => "U12 Spring Flag 2012",
      :amount => 100.00
    )
    pp = PaymentPackage.create(
      :club => rchfc,
      :season_division => springsdu12,
      :name => "U12 Spring Flag 2012",
      :amount => 100.00
    )
    pp = PaymentPackage.create(
      :club => rchfc,
      :season_division => springsdu14,
      :name => "U14 Spring Flag 2012",
      :amount => 100.00
    )
    pp = PaymentPackage.create(
      :club => rchfc,
      :season_division => summersdflag,
      :name => "Flag 2012",
      :amount => 50.00
    )
    pp = PaymentPackage.create(
      :club => rchfc,
      :season_division => summersdatom,
      :name => "Atom 2012",
      :amount => 150.00
    )
    pp = PaymentPackage.create(
      :club => rchfc,
      :season_division => summersdpeewee,
      :name => "Peewee 2012",
      :amount => 200.00
    )
    pp = PaymentPackage.create(
      :club => rchfc,
      :season_division => summersdjb,
      :name => "Junior Bantam 2012",
      :amount => 250.00
    )
    pp = PaymentPackage.create(
      :club => rchfc,
      :season_division => cheersd,
      :name => "Cheerleading 2012",
      :amount => 150.00
    )
  end

  def self.down
  end
end
