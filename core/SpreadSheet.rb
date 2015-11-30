# Coding: UTF-8
require "google_drive"

class SpreadSheeet
  attr_accessor :ws, :ss
  
  def initialize client_id, client_secret, refresh_token, spread_id, worksheet_id=0
    client = OAuth2::Client.new(
    client_id,
    client_secret,
    site: "https://accounts.google.com",
    token_url: "/o/oauth2/token",
    authorize_url: "/o/oauth2/auth")
    auth_token = OAuth2::AccessToken.from_hash(client,{:refresh_token => refresh_token, :expires_at => 3600})
    auth_token = auth_token.refresh!
    session = GoogleDrive.login_with_oauth(auth_token.token)
    self.ss = session.spreadsheet_by_key(spread_id)
    self.ws = self.ss.worksheets[worksheet_id]
    @hostKey = ["Date", "cpuUsed", "cpuFree", "cpuRatio", "memoryUsed", "memoryFree", "memoryRatio", "uptime", "operatingVms", "w"]
    @vmKey = ["Date", "name", "cpuUsed", "cpuFree", "cpuRatio", "memoryUsed", "memoryFree", "memoryRatio", "uptime", "w"]
  end
  
  def num_rows
    self.ws.num_rows
  end
  
  def hostPush data
    ary = [@hostKey,data].transpose
    self.ws.list.push Hash[*ary.flatten]
  ensure
    self.ws.save
  end

  def vmPush data
    ary = [@vmKey,data].transpose
    self.ws.list.push Hash[*ary.flatten]
  ensure
    self.ws.save
  end

  def write data
    self.ws.update_cells(2, 1, data)
  ensure
    self.ws.save
  end
  
  def add_worksheet name
    self.ss.add_worksheet(name, max_rows = 200, max_cols = 20)
  end
  
  def worksheet_by_title name
    ws = self.ss.worksheet_by_title(name)
    if ws.nil?
      ws = add_worksheet(name)
      ws.update_cells(1, 1, [@vmKey])
      ws.save
    end
    self.ws = self.ss.worksheet_by_title(name)
  end
end


