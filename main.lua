local WidgetContainer = require("ui/widget/container/widgetcontainer")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local Event = require("ui/event")

local DictToNotePlugin = WidgetContainer:extend{
    name = "dicttonote",
    is_doc_only = false,
}

function DictToNotePlugin:init()
    -- Register button with the new KOReader dict API (PR #15184+)
    -- Safe no-op on older versions where addToDictButtons doesn't exist.
    if self.ui and self.ui.dictionary and type(self.ui.dictionary.addToDictButtons) == "function" then
        self.ui.dictionary:addToDictButtons({
            id = "save_note",
            menu_text = "Save + Note",
            text = "Save + Note",
            conditional = true,   -- always appended at runtime, not user-toggleable
            callback = function(dict_popup)
                -- KOReader passes the dictionary popup instance directly to the callback
                self:_saveNoteAction(dict_popup)
            end
        })
    end
end

-- Legacy fallback support for older KOReader versions
function DictToNotePlugin:onDictButtonsReady(dict_popup, buttons)
    if not (self.ui and self.ui.dictionary and type(self.ui.dictionary.addToDictButtons) == "function") then
        table.insert(buttons, {
            {
                id = "save_note",
                text = "Save + Note",
                callback = function()
                    self:_saveNoteAction(dict_popup)
                end
            }
        })
    end
end

-- Core processing module for text extraction and note saving
function DictToNotePlugin:_saveNoteAction(dict_popup)
    local dict_text = ""
    
    local idx = dict_popup.dict_index or 1
    if dict_popup.results and dict_popup.results[idx] then
        dict_text = dict_popup.results[idx].definition or ""
        
        dict_text = dict_text:gsub("<br%s*/?>", "\n")
        dict_text = dict_text:gsub("</p>", "\n")
        dict_text = dict_text:gsub("</div>", "\n")
        
        dict_text = dict_text:gsub("<ol[^>]*>(.-)</ol>", function(ol_content)
            local counter = 1
            ol_content = ol_content:gsub("<li[^>]*>(.-)</li>", function(li_content)
                local res = "\n" .. counter .. ". " .. li_content
                counter = counter + 1
                return res
            end)
            ol_content = ol_content:gsub("<li[^>]*>", function()
                local res = "\n" .. counter .. ". "
                counter = counter + 1
                return res
            end)
            return ol_content .. "\n"
        end)
        
        dict_text = dict_text:gsub("<li[^>]*>(.-)</li>", "\n• %1")
        dict_text = dict_text:gsub("<li[^>]*>", "\n• ")
        dict_text = dict_text:gsub("</ul>", "\n")
        dict_text = dict_text:gsub("</ol>", "\n")
        dict_text = dict_text:gsub("<[^>]+>", "")
        dict_text = dict_text:gsub("\n\n+", "\n\n")
        dict_text = dict_text:gsub("^%s*(.-)%s*$", "%1")
    end
    
    local sentence = dict_popup.sentence or ""
    local note_payload = dict_text
    if sentence ~= "" then
        note_payload = note_payload .. "\n\nContext:\n" .. sentence
    end
    
    local ui = dict_popup.ui
    local highlight_module = ui and ui.highlight
    local annotation_module = ui and ui.annotation
    
    UIManager:close(dict_popup)
    
    if highlight_module and annotation_module then
        local annot_id = highlight_module:saveHighlight(true)
        if annot_id and annotation_module.annotations then
            local annotation = annotation_module.annotations[annot_id]
            if annotation then
                annotation.note = note_payload
                ui:handleEvent(Event:new("AnnotationsModified", {
                    annotation,
                    nb_highlights_added = -1,
                    nb_notes_added = 1
                }))
                highlight_module:onClose()
                UIManager:show(InfoMessage:new{
                    text = "Highlight + Note saved!",
                })
            end
        end
    end
end

return DictToNotePlugin