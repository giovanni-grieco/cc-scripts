-- install.lua
-- Description: this script install basix, downloading basic unix-like programs and updating startup.lua to provide autocompletion for the installed programs

-- Constants
local url_prefix = "https://game-hub.it/basix/"

local file_list_url = url_prefix .. "filelist"

print("Downloading file list from "  .. file_list_url)

local file_list = http.get(file_list_url).readAll()

local file_list_lines = {}


-- Utility functions

local function save_file(path, file_name, content)
    local file = fs.open(path .. file_name, "w")
    if file then
        file.write(content)
        file.close()
        print("Saved " .. file_name .. " to " .. path)
    else
        print("Failed to save " .. file_name)
    end
end

local function download_file(url)
    local response = http.get(url)
    if response then
        local file_data = response.readAll()
        local file_name = url:match("([^/]+)$")
        return file_name, file_data
    else
        print("Failed to download " .. url)
    end
end

local function get_folders_to_create()
    local folders = {}
    for line in file_list:gmatch("[^\r\n]+") do
        -- check if the folder exists in the folders collection
        local folder_path = line:match("(.*/)")
        for _, folder in ipairs(folders) do
            if folder ~= folder_path then
                table.insert(folders, folder_path)
            end
        end
    end
    return folders
end

-- Main Script

local function main()
    local folders_to_create = get_folders_to_create()
    for _, folder in ipairs(folders_to_create) do
        if not fs.exists(folder) then
            fs.makeDir(folder)
            print("Created folder: " .. folder)
        else
            print("Folder already exists: " .. folder)
        end
    end
    
    for line in file_list:gmatch("[^\r\n]+") do
      table.insert(file_list_lines, line)
    end
    
    for i, line in ipairs(file_list_lines) do
        local file_url = url_prefix .. line
        local file_name = line:match("([^/]+)$")
        local file_path = line:match("(.*/)")
        print("Downloading " .. file_name .. " from " .. file_url)
        local file_name, file_data = download_file(file_url)
        if file_name and file_data then
            if file_name:match("startup.lua") then
                save_file("/", file_name, file_data)
            else
                save_file(file_path, file_name, file_data)
            end
            print("Downloaded " .. file_name .. " successfully.")
        else
            print("Failed to download " .. file_name)
        end
    end
    print("Basix installation complete.")
    print("Please restart your computer to apply changes. (Hold CTRL+R)")
end

main()
-- End of script

