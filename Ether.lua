-- Inofficial Ethereum Extension for MoneyMoney
-- Fetches Ether quantity for address via etherscan API
-- Fetches Ether price in EUR via cryptocompare API
-- Returns cryptoassets as securities
--
-- Username: Ethereum Adresses comma seperated
-- Password: Etherscan API-Key

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
  version = 0.1,
  description = "Include your Ether as cryptoportfolio in MoneyMoney by providing a Etheradresses (usernme, comma seperated) and etherscan-API-Key (Password)",
  services= { "Ethereum" }
}

local ethAddresses
local etherscanApiKey
local connection = Connection()
local currency = "EUR" -- fixme: make dynamik if MM enables input field

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Ethereum"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  ethAddresses = username:gsub("%s+", "")
  etherscanApiKey = password
end

function ListAccounts (knownAccounts)
  local account = {
    name = "Ethereum",
    accountNumber = "Crypto Asset Ethereum",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}
  prices = requestEthPrice()

  for address in string.gmatch(ethAddresses, '([^,]+)') do
    weiQuantity = requestWeiQuantityForEthAddress(address)
    ethQuantity = convertWeiToEth(weiQuantity)

    s[#s+1] = {
      name = address,
      currency = nil,
      market = "cryptocompare",
      quantity = ethQuantity,
      price = prices["EUR"],
    }
  end

  return {securities = s}
end

function EndSession ()
end


-- Querry Functions
function requestEthPrice()
  content = connection:request("GET", cryptocompareRequestUrl(), {})
  json = JSON(content)

  return json:dictionary()
end

function requestWeiQuantityForEthAddress(ethAddress)
  content = connection:request("GET", etherscanRequestUrl(ethAddress), {})
  json = JSON(content)

  return json:dictionary()["result"]
end


-- Helper Functions
function convertWeiToEth(wei)
  return wei / 1000000000000000000 
end

function cryptocompareRequestUrl()
  return "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=EUR,USD"
end 

function etherscanRequestUrl(ethAddress)
  etherscanRoot = "https://api.etherscan.io/api?"
  params = "&module=account&action=balance&tag=latest"
  address = "&address=" .. ethAddress
  apiKey = "&apikey=" .. etherscanApiKey

  return etherscanRoot .. params .. address .. apiKey
end

