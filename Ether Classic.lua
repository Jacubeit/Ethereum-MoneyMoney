-- Inofficial Ethereum Classic Extension for MoneyMoney
-- Fetches ETC quantity for address via etcchain API
-- Fetches ETC price in EUR via cryptocompare API
-- Returns cryptoassets as securities
--
-- Username: Ethereum Classic Adresses comma seperated
-- Password: Whatever

-- MIT License

-- Copyright (c) 2017 Jacubeit

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


WebBanking{
  version = 0.2,
  description = "Include your Ether as cryptoportfolio in MoneyMoney by providing a Etheradresses (usernme, comma seperated) and etherscan-API-Key (Password)",
  services= { "Ethereum Classic" }
}

local etcAddress
local connection = Connection()
local currency = "EUR" -- fixme: make dynamik if MM enables input field

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Ethereum Classic"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  etcAddress = username
end

function ListAccounts (knownAccounts)
  local account = {
    name = "Ethereum Classic",
    accountNumber = "Crypto Asset Ethereum Classic",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}
  prices = requestEtcPrice()

  for address in string.gmatch(etcAddress, '([^,]+)') do
    ethClQuantity = requestEtcClQuantityForEtcAddress(address)

    s[#s+1] = {
      name = address,
      currency = nil,
      market = "cryptocompare",
      quantity = ethClQuantity,
      price = prices["EUR"],
    }
  end

  return {securities = s}
end

function EndSession ()
end


-- Querry Functions
function requestEtcPrice()
  content = connection:request("GET", cryptocompareRequestUrl(), {})
  json = JSON(content)

  return json:dictionary()
end

function requestEtcClQuantityForEtcAddress(etcAddress)
  content = connection:request("GET", blockscoutRequestUrl(etcAddress), {})
  json = JSON(content)

  return tonumber(json:dictionary()["result"]) / 1000000000000000000
end


-- Helper Functions
function cryptocompareRequestUrl()
  return "https://min-api.cryptocompare.com/data/price?fsym=ETC&tsyms=EUR,USD"
end 

function blockscoutRequestUrl(etcAddress)
  blockscout = "https://blockscout.com/etc/mainnet/api?module=account&action=eth_get_balance"
  address = "&address=" .. etcAddress

  return blockscout .. address
end

