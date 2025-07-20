local html = require("html")

function id() return "nightsup_clean" end
function name() return "NightSup Clean" end
function lang() return "en" end
function version() return 1 end

local base = "https://nightsup.net"

local function parse_cards(doc)
    local mangas = {}
    for _, card in ipairs(doc:select("div.page-item-detail")) do
        local a = card:select("h3.h5 > a")
        table.insert(mangas, {
            title = a:text(),
            url = a:attr("href"),
            thumbnail_url = card:select("img"):attr("src") 
                              or card:select("img"):attr("data-src")
        })
    end
    return mangas
end

function popular_manga(page)
    local res = http.get(base .. "/manga/page/" .. page)
    return parse_cards(html.parse(res.body))
end

function latest_manga(page)
    local res = http.get(base .. "/manga/page/" .. page .. "/?order=update")
    return parse_cards(html.parse(res.body))
end

function search_manga(query, page, filters)
    local res = http.get(base .. "/page/" .. page .. "/?s=" .. query)
    return parse_cards(html.parse(res.body))
end

function manga_details(url)
    local doc = html.parse(http.get(url).body)
    local title = doc:select("div.post-title > h1"):text()
    local author = doc:select("div.author-content > a"):text()
    local desc = doc:select("div.description-summary"):text()
    local genres = {}
    for _, g in ipairs(doc:select("div.genres-content a")) do
        table.insert(genres, g:text())
    end
    return {
        title = title, author = author, description = desc,
        genres = genres, status = 1, url = url
    }
end

function chapter_list(url)
    local doc = html.parse(http.get(url).body)
    local chapters = {}
    for _, c in ipairs(doc:select("ul.main li.wp-manga-chapter a")) do
        table.insert(chapters, {title = c:text(), url = c:attr("href")})
    end
    return chapters
end

function page_list(url)
    local doc = html.parse(http.get(url).body)
    local pages = {}
    for _, img in ipairs(doc:select("div.reading-content img")) do
        local src = img:attr("src") or img:attr("data-src")
        table.insert(pages, src)
    end
    return pages
end
