#- XLsuite, an integrated CMS, CRM and ERP for medium businesses
#- Copyright 2005-2009 iXLd Media Inc.  See LICENSE for details.

class Sender < Recipient
  before_create {|r| r.read_at = Time.now}
end
