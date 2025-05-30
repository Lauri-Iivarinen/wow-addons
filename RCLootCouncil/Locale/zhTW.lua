-- Translate RCLootCouncil to your language at:
-- http://wow.curseforge.com/addons/rclootcouncil/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("RCLootCouncil", "zhTW")
if not L then return end

L[" is not active in this raid."] = "在當前團隊中未啟用。"
L[" you are now the Master Looter and RCLootCouncil is now handling looting."] = "你現在是分裝者，RCLootCouncil開始管理分配。"
L["&p was awarded with &i for &r!"] = "&p獲得了&i，理由為&r！"
L["A format to copy/paste to another player."] = "一個可以給其他玩家復制/粘貼的格式。"
L["A new session has begun, type '/rc open' to open the voting frame."] = "新的分配已經開始，輸入'/rc open'開啟投票介面"
L["Abort"] = "中止"
L["Accept Whispers"] = "接受密語"
L["accept_whispers_desc"] = "允許玩家密語他們當前的物品給你，以添加到分配界面。"
--[[Translation missing --]]
L["Accepted imports: 'Player Export' and 'CSV'"] = "Accepted imports: 'Player Export' and 'CSV'"
L["Active"] = "啓用"
L["active_desc"] = "取消勾選以禁用RCLootCouncil。當你在團隊中但沒參與副本活動時這很有用。備注：此選項在每次登出時重置。"
L["Add Item"] = "添加物品"
L["Add Note"] = "增加筆記"
L["Add ranks"] = "增加階級"
L["Add rolls"] = "添加擲骰"
L["Add Rolls"] = "添加擲骰"
--[[Translation missing --]]
L["add_candidate"] = "Add Candidate"
L["add_ranks_desc"] = "擇參與戰利品分配議會的最低會階"
L["add_ranks_desc2"] = [=[
在上方選擇一個會階，添加該會階以及高於此會階的所有公會成員為議會成員。

點擊左側的會階，添加指定玩家為議會成員。

點擊"當前議會成員"頁來查看你所選擇的成員。]=]
L["add_rolls_desc"] = "自動給所有會話添加1-100的擲點。"
L["Additional Buttons"] = "額外按鈕"
L["All items"] = "所有物品"
L["All items have been awarded and the loot session concluded"] = "所有裝備都已經分配完成，結束分裝程序。"
L["All items usable by the candidate"] = "所有此人可用的物品"
L["All unawarded items"] = "所有未分配物品"
L["Alternatively, flag the loot as award later."] = "另外，標記該物品為稍后分配。"
--[[Translation missing --]]
L["Always show owner"] = "Always show owner"
L["Always use RCLootCouncil with Personal Loot"] = "個人拾取時總是使用RCLootCouncil"
L["always_show_tooltip_howto"] = "雙擊切換是否總顯示tooltip"
L["Announce Awards"] = "通知分配"
L["Announce Considerations"] = "通知考慮的物品"
L["announce_&i_desc"] = "|cfffcd400 &i|r: 物品連結"
L["announce_&l_desc"] = "|cfffcd400 &l|r: 物品等級"
--[[Translation missing --]]
L["announce_&m_desc"] = "|cfffcd400 &m|r: candidates note."
L["announce_&n_desc"] = "|cfffcd400 &n|r: 擲骰結果，如果有的話。"
L["announce_&o_desc"] = "|cfffcd400 &o|r: 裝備擁有人， 如果適用。"
L["announce_&p_desc"] = "|cfffcd400 &p|r: 獲得物品的玩家名稱"
L["announce_&r_desc"] = "|cfffcd400 &r|r: 理由"
L["announce_&s_desc"] = "|cfffcd400 &s|r: 會話id。"
L["announce_&t_desc"] = "|cfffcd400 &t|r: 物品類別"
L["announce_awards_desc"] = "啟用聊天分配通知。"
L["announce_awards_desc2"] = [=[
選擇要通告物品分配信息的頻道。提供以下關鍵字替換：]=]
L["announce_considerations_desc"] = "當分配開始時通知待決定物品。"
L["announce_considerations_desc2"] = [=[
選擇你想通告的頻道和消息。
該消息將出現在物品列表之前。]=]
L["announce_item_string_desc"] = [=[
輸入每件物品的通告文字。提供以下關鍵字替換：]=]
L["Announcements"] = "通知"
L["Anonymous Voting"] = "匿名投票"
L["anonymous_voting_desc"] = "開啟匿名投票，成員無法看到誰投給了誰。"
L["Append realm names"] = "附加伺服器名稱"
L["Are you sure you want to abort?"] = "確定中止分配？"
L["Are you sure you want to give #item to #player?"] = "確定將%s分配給%s？"
L["Are you sure you want to reannounce all unawarded items to %s?"] = "你確定要向 %s 重新通告所有未分配物品嗎？"
L["Are you sure you want to request rolls for all unawarded items from %s?"] = "你確定要讓 %s 對所有未分配物品擲點嗎？"
L["Armor Token"] = "裝備代幣"
L["Ask me every time Personal Loot is enabled"] = "每次個人拾取啟動時詢問我"
L["Auto Award"] = "自動分配"
L["Auto Award to"] = "自動分配給"
L["Auto awarded 'item'"] = "自動分配%s"
L["Auto Close"] = "自動關閉"
L["Auto Enable"] = "自動啓用"
L["Auto extracted from whisper"] = "自動從密語中擷取"
L["Auto Open"] = "自動開啓"
L["Auto Pass"] = "自動放棄"
L["Auto pass BoE"] = "自動放棄裝綁"
--[[Translation missing --]]
L["Auto Pass Transmog"] = "Auto Pass Transmog"
--[[Translation missing --]]
L["Auto Pass Transmog Source"] = "Auto Pass Transmog Source"
L["Auto Pass Trinkets"] = "自動放棄飾品"
--[[Translation missing --]]
L["Auto Trade"] = "Auto Trade"
L["auto_award_desc"] = "啓用自動分配"
L["auto_award_to_desc"] = "自動獲得物品的玩家"
L["auto_close_desc"] = "分裝者結束分裝程序後自動關閉投票視窗"
L["auto_enable_desc"] = "總是允許RCLootCouncil 管理拾取。不勾每次加入隊伍或獲得分裝權時都會詢問"
L["auto_open_desc"] = "自動開啟分配界面。不勾也可輸入/rc open 手動開啟但需要分裝者授權"
L["auto_pass_boe_desc"] = "自動放棄裝備綁定物品"
L["auto_pass_desc"] = "自動放棄你不能用的物品"
--[[Translation missing --]]
L["auto_pass_transmog_desc"] = "Check to enable autopassing of items your class can only use for transmog."
--[[Translation missing --]]
L["auto_pass_transmog_source_desc"] = "Check to enable autopassing of items your class can only use for transmog and the appearance is already known from another item."
L["auto_pass_trinket_desc"] = "選中以自動放棄地下城手冊中不屬於你的職業的飾品"
--[[Translation missing --]]
L["autoGroupLoot_warning"] = "Note: Group Leader's settings will cause RCLootCouncil to automatically control group loot."
L["autoloot_others_item_combat"] = "%s 拾取了%s。此物品將會在戰斗結束后加入分配。"
L["Autopass"] = "自動放棄"
L["Autopassed on 'item'"] = "自動放棄%s"
L["Autostart isn't supported when testing"] = "無法在測試中自動分配"
L["award"] = "獎勵"
L["Award"] = "分配"
L["Award Announcement"] = "通知分配"
L["Award for ..."] = "分配爲..."
L["Award later"] = "稍后分配"
L["Award later isn't supported when testing."] = "測試模式不支持稍后分配。"
L["Award later?"] = "稍後分配?"
L["Award Reasons"] = "分配理由"
L["award_reasons_desc"] = [=[用於自動分配時右鍵選單中
擲骰時無法選擇分配理由]=]
L["Awarded"] = "已分配"
L["Awarded item cannot be awarded later."] = "已分配物品無法被稍后分配。"
L["Awards"] = "分配"
L["Background"] = "背景"
L["Background Color"] = "背景顏色"
L["Banking"] = "收藏"
L["BBCode export, tailored for SMF."] = "BBCode輸出，為SMF設計。"
L["Border"] = "邊界"
L["Border Color"] = "邊界顏色"
L["Button"] = "按鈕"
L["Buttons and Responses"] = "按鈕和回應"
L["buttons_and_responses_desc"] = "設定團隊拾取介面的回應按鈕"
L["Candidate didn't respond on time"] = "可拾取成員沒有及時回應"
L["Candidate has disabled RCLootCouncil"] = "可拾取成員禁用了RCLootCouncil"
L["Candidate is not in the instance"] = "可拾取成員不在副本內"
L["Candidate is selecting response, please wait"] = "可拾取成員正在回應，請稍候"
L["Candidate removed"] = "移除可拾取成員"
L["Candidates that can't use the item"] = "無法使用此物品的人"
L["Cannot autoaward:"] = "無法自動分配："
L["Cannot give 'item' to 'player' due to Blizzard limitations. Gave it to you for distribution."] = "由於暴雪限制，你無法將%s分配給%s"
--[[Translation missing --]]
L["Catalyst_Items"] = "Catalyst Items"
L["Change Award"] = "變更分配"
L["Change Response"] = "更改回應"
L["Changing loot threshold to enable Auto Awarding"] = "更改拾取品質以啟用自動分配"
L["Changing LootMethod to Master Looting"] = "分配方式更改爲隊長分配"
L["channel_desc"] = "發送信息的頻道"
--[[Translation missing --]]
L["Chat print"] = "Chat print"
L["chat tVersion string"] = "|cFF87CEFARCLootCouncil |cFFFFFFFF版本 |cFFFFA500 %s - %s"
L["chat version String"] = "|cFF87CEFARCLootCouncil |cFFFFFFFF版本 |cFFFFA500 %s"
--[[Translation missing --]]
L["chat_cmd_add_found_items"] = "Found %d items with trade timers in your bags."
--[[Translation missing --]]
L["chat_cmd_add_invalid_owner"] = "The player %s was either invalid or not a candidate."
--[[Translation missing --]]
L["chat_command_start_error_onlyUseInRaids"] = "Cannot start: you're in a party and have the 'only use in raids' option enabled."
--[[Translation missing --]]
L["chat_command_start_error_start_PartyIsLFG"] = "Cannot start: you are in a LFG party."
--[[Translation missing --]]
L["chat_command_start_error_usageNever"] = "Cannot start: your 'usage' option is set to 'never'."
L["chat_commands_add"] = "將一個物品加入分配"
--[[Translation missing --]]
L["chat_commands_add_all"] = "Adds all tradable items to the session frame"
L["chat_commands_award"] = "開始分配你之前稍后分配的物品。"
--[[Translation missing --]]
L["chat_commands_clear"] = "Removes all items from the 'award later' list"
L["chat_commands_config"] = "打開設置界面"
L["chat_commands_council"] = "打開議會界面"
--[[Translation missing --]]
L["chat_commands_export"] = "Exports the items currently in session"
--[[Translation missing --]]
L["chat_commands_groupLeader_only"] = "Group Leader commands"
L["chat_commands_history"] = "打開歷史界面(簡稱： 'h' 或者 'his')"
--[[Translation missing --]]
L["chat_commands_list"] = "Lists all items marked for 'award later'"
--[[Translation missing --]]
L["chat_commands_ML_only"] = "Master Looter commands"
L["chat_commands_open"] = "打開投票界面"
--[[Translation missing --]]
L["chat_commands_profile"] = "Open the profile manager"
--[[Translation missing --]]
L["chat_commands_remove"] = "Removes the item at index from the 'award later' list"
L["chat_commands_reset"] = "重置界面位置"
--[[Translation missing --]]
L["chat_commands_session"] = "Open the session frame (alt. 'ses' or 's')"
--[[Translation missing --]]
L["chat_commands_start"] = "Start handling loot"
--[[Translation missing --]]
L["chat_commands_stop"] = "Stop handling loot"
L["chat_commands_sync"] = "打開設置同步器"
L["chat_commands_test"] = "模擬有#個物品的分配進程。如果省略默認為一個物品"
--[[Translation missing --]]
L["chat_commands_trade"] = "Open the TradeUI"
L["chat_commands_version"] = "打開版本檢查器 (簡稱： 'v' 或者 'ver')"
L["chat_commands_whisper"] = "顯示密語幫助"
--[[Translation missing --]]
L["chatCommand_stop_error_notHandlingLoot"] = "Cannot stop: not currently handling loot."
L["Check this to loot the items and distribute them later."] = "點擊拾取物品稍後分配"
L["Check to append the realmname of a player from another realm"] = "顯示不同伺服器玩家的伺服器名稱"
L["Check to have all frames minimize when entering combat"] = "進入戰鬥時最小化"
L["Choose timeout length in seconds"] = "選擇超時時間限制(秒)"
L["Choose when to use RCLootCouncil"] = "選擇何時使用RCLootCouncil"
L["Clear Loot History"] = "清除拾取歷史"
L["Clear Selection"] = "清除選擇"
L["clear_loot_history_desc"] = "刪除全部拾取歷史"
L["Click to add note to send to the council."] = "點擊添加要發送給議會的筆記。"
L["Click to change your note."] = "點擊修改筆記。"
L["Click to expand/collapse more info"] = "點擊展開/收起"
L["Click to switch to 'item'"] = "點擊切換為%s"
L["config"] = "設定"
L["confirm_award_later_text"] = "你確認稍后分配物品%s嗎？此物品將會被記錄在插件的稍后分配列表中。如果此物品在拾取窗口中，你將拾取此物品。你可以之后使用命令'/rc award'分配此物品。"
L["confirm_usage_text"] = [=[|cFF87CEFA RCLootCouncil |r 

是否在此隊伍使用RCLootCouncil?]=]
L["Conqueror Token"] = "征服者代幣"
--[[Translation missing --]]
L["Corruption if awarded:"] = "Corruption if awarded:"
L["Could not Auto Award i because the Loot Threshold is too high!"] = "無法自動分配%s 因為拾取門欄過高"
L["Could not find 'player' in the group."] = "隊伍中無法找到%s"
L["Couldn't find any councilmembers in the group"] = "無法在隊伍內找到投票成員"
L["council"] = "投票成員"
L["Council"] = "投票成員"
L["Current Council"] = "目前投票成員"
L["current_council_desc"] = [=[
點擊將特定玩家從可拾取成員中移除]=]
L["Customize appearance"] = "客製外觀"
L["customize_appearance_desc"] = "你可以在這邊客製RCLootCouncil的外觀。點擊上面的保存鍵更換外觀。"
L["Data Received"] = "數據已接收"
L["Date"] = "日期"
L["days and x months"] = "%s，%d月"
L["days, x months, y years"] = "%s，%d月和%d年"
L["Delete Skin"] = "刪除外觀"
L["delete_skin_desc"] = "從選單中刪除目前選取的非預設外觀"
L["Deselect responses to filter them"] = "取消回應以過濾"
L["Diff"] = "差異"
L["Discord friendly output."] = "Discord格式輸出"
L["disenchant_desc"] = "當你經由分解按鈕贏得物品時使用這個理由"
--[[Translation missing --]]
L["Do you want to keep %s for yourself or trade?"] = "Do you want to keep %s for yourself or trade?"
L["Done syncing"] = "同步結束"
L["Double click to delete this entry."] = "點擊兩下刪除此條目"
L["Dropped by:"] = "掉落來源:"
L["Edit Entry"] = "編輯項目"
L["Enable Loot History"] = "啓用拾取歷史"
L["Enable Timeout"] = "啟用超時限制"
L["enable_loot_history_desc"] = "啓用拾取歷史。如果關閉RCLootCouncil 將不會記錄任何數據。"
L["enable_timeout_desc"] = "點選啟動拾取視窗超時功能"
L["Enter your note:"] = "輸入你的筆記："
L["EQdkp-Plus XML output, tailored for Enjin import."] = "EQdkp-Plus XML輸出，適用於Enjin輸入。"
L["error_test_as_non_leader"] = "你無法在隊伍中以非隊長的身分啟動測試"
--[[Translation missing --]]
L["Everybody is up to date."] = "Everybody is up to date."
L["Everyone have voted"] = "所有投票成員都已投票"
L["Export"] = "輸出"
--[[Translation missing --]]
L["Fake Loot"] = "Fake Loot"
L["Following items were registered in the award later list:"] = "以下物品已被稍后分配列表登記："
L["Following winners was registered:"] = "下個贏家已登記："
--[[Translation missing --]]
L["Found the following outdated versions"] = "Found the following outdated versions"
L["Frame options"] = "框架選項"
L["Free"] = "自由拾取"
--[[Translation missing --]]
L["Full Bags"] = "Full Bags"
L["g1"] = "1"
L["g2"] = "2"
L["Gave the item to you for distribution."] = "將物品給你分配。"
L["General options"] = "一般選項"
L["Group Council Members"] = "隊伍分配者"
L["group_council_members_desc"] = "添加其他伺服器或其他公會的可拾取成員"
L["group_council_members_head"] = "從目前隊伍添加可拾取成員"
L["Guild Council Members"] = "公會分配者"
L["Hide Votes"] = "隱藏投票"
L["hide_votes_desc"] = "隱藏投票數直到有人投票"
--[[Translation missing --]]
L["history_export_excel_international_tip"] = "Tab delimited export for international version of Excel that uses ',' as formula delimiter."
--[[Translation missing --]]
L["history_export_sheets_tip"] = "Tab delimited export for Google Sheets and English version of Excel that uses ';' as formula delimiter."
L["How to sync"] = "如何同步"
L["huge_export_desc"] = "大量數據。隻顯示第一行以避免游戲卡頓。可以使用Ctrl+C復制全部內容。"
L["Ignore List"] = "忽略列表"
L["Ignore Options"] = "忽略選項"
L["ignore_input_desc"] = "輸入一個物品ID 將其添加至忽略列表, RCLootCouncil 永遠不會將此物品加入分配"
L["ignore_input_usage"] = "只接受物品ID(數字)"
L["ignore_list_desc"] = "物品已被RCLootCouncil忽略，點擊物品來移除。"
L["ignore_options_desc"] = "控制RCLootCouncil忽略的物品。 如果添加的物品未找到，請切到其他介面, 然後返回，這樣你就可以看到了。"
--[[Translation missing --]]
L["Import"] = "Import"
--[[Translation missing --]]
L["Import aborted"] = "Import aborted"
L["import_desc"] = "將數據粘貼於此。隻顯示前2500個字符以避免游戲卡頓。"
--[[Translation missing --]]
L["import_malformed"] = "The import was malformed (not a string)"
--[[Translation missing --]]
L["import_malformed_header"] = "Malformed header"
--[[Translation missing --]]
L["import_not_supported"] = "The import type is either very malformed or not supported."
L["Invalid selection"] = "無效選擇"
L["Item"] = "物品"
L["'Item' is added to the award later list."] = "%s被加入到了稍后分配列表了。"
L["Item quality is below the loot threshold"] = "物品品質低於物品分配界限。"
L["Item received and added from 'player'"] = "物品已收到，來自%s"
L["Item was awarded to"] = "物品被分配給"
L["Item(s) replaced:"] = "取代物品:"
L["item_in_bags_low_trade_time_remaining_reminder"] = "你的背包中的以下在稍后分配列表的物品剩余交易時間不足%s。如果你想避免此提示，交易該物品，使用‘/rc remove [index]’將物品從列表中移除，使用‘/rc clear’清空列表，或者裝備該物品使其無法被交易。"
L["Items stored in the loot master's bag for award later cannot be awarded later."] = "存放在戰利品分配者背包內的物品無法被稍后分配。"
L["Items under consideration:"] = "待決定的物品："
--[[Translation missing --]]
L["Keep"] = "Keep"
L["Latest item(s) won"] = "上一次取得物品:"
L["Length"] = "長度"
L["Log"] = "日誌"
L["log_desc"] = "啓用拾取歷史記錄"
L["Loot announced, waiting for answer"] = "拾取已發送，正在等待回應"
L["Loot History"] = "拾取歷史"
--[[Translation missing --]]
L["Loot Status"] = "Loot Status"
L["Loot won:"] = "獲得裝備:"
L["loot_history_desc"] = [=[RCLootCouncil 將自動記錄分配相關訊息
原始數據儲存於".../SavedVariables/RCLootCouncil.lua" 

注意: 非分裝者只能記錄來自分裝者發送的數據]=]
--[[Translation missing --]]
L["Looted"] = "Looted"
L["Looted by:"] = "拾取人: "
--[[Translation missing --]]
L["lootFrame_error_note_required"] = "You must add a note before submitting your response - %s"
--[[Translation missing --]]
L["lootHistory_moreInfo_winnersOfItem"] = "Winners of %s:"
L["Looting options"] = "拾取選項"
L["Lower Quality Limit"] = "最低品質"
L["lower_quality_limit_desc"] = "選擇自動分配時物品的最低品質"
L["Mainspec/Need"] = "主天賦/需求"
L["Mass deletion of history entries."] = "大量刪除拾取歷史"
L["Master Looter"] = "分裝者"
L["master_looter_desc"] = "注意: 這些設置僅供分裝者使用"
L["Message"] = "訊息"
L["Message for each item"] = "每件物品的信息"
L["message_desc"] = "訊息已發送至所選頻道"
L["Minimize in combat"] = "戰鬥中最小化"
L["Minor Upgrade"] = "小提升"
--[[Translation missing --]]
L["Missing votes from:"] = "Missing votes from:"
L["ML sees voting"] = "分裝者可見投票"
--[[Translation missing --]]
L["ML_ADD_INVALID_ITEM"] = "Invalid itemLink or itemID: %s"
--[[Translation missing --]]
L["ML_ADD_ITEM_MAX_ATTEMPTS"] = "Couldn't fetch item info for %s - probably not a real item."
L["ml_sees_voting_desc"] = "允許分裝者查看投票詳情"
L["module_tVersion_outdated_msg"] = "最新模塊 %s 的測試版本為: %s"
L["module_version_outdated_msg"] = "模塊 %s 版本 %s 已過期。新版本為 %s。"
L["Modules"] = "模組"
L["More Info"] = "更多訊息"
L["more_info_desc"] = "選擇希望看到幾名回覆者上一次獲得物品。例: 選擇2(預設)會顯示上一次主天賦及副天賦所獲得的裝備以及多久以前獲得。"
L["Multi Vote"] = "多選投票"
L["multi_vote_desc"] = "允許投票者可以投給多個可拾取成員"
L["'n days' ago"] = "%s前"
L["Never use RCLootCouncil"] = "禁用RCLootCouncil"
L["new_ml_bagged_items_reminder"] = "你的稍后分配列表中有近期的物品。‘/rc list’以查看列表，‘/rc clear’以清空列表，'/rc remove [index]'以移除列表中的某一項，‘/rc award’分配稍后分配列表中的物品，‘/rc add’並在窗口中勾選稍后分配以把物品加入稍后分配列表。"
L["No (dis)enchanters found"] = "團隊中沒人會分解"
L["No entries in the Loot History"] = "獲取記錄中沒有資料"
L["No entry in the award later list is removed."] = "未移除稍后分配列表中的任何一項。"
L["No items to award later registered"] = "沒有物品登記"
L["No recipients available"] = "沒有可分配人選"
L["No session running"] = "目前沒有分配進行中"
L["No winners registered"] = "沒有贏家登記"
L["non_tradeable_reason_nil"] = "不明"
L["non_tradeable_reason_not_tradeable"] = "無法交易"
L["non_tradeable_reason_rejected_trade"] = "想要保留裝備"
L["Non-tradeable reason:"] = "無法交易原因: "
L["Not announced"] = "沒有公佈"
L["Not cached, please reopen."] = "沒有存入，請重新打開"
L["Not Found"] = "沒找到"
L["Not in your guild"] = "不在你的公會"
L["Not installed"] = "沒有安裝"
L["Notes"] = "筆記"
L["Now handles looting"] = "現在負責拾取"
L["Number of buttons"] = "按鈕數量"
L["Number of raids received loot from:"] = "團本中獲得物品數量："
L["Number of reasons"] = "理由數量"
L["Number of responses"] = "回覆數量"
L["number_of_buttons_desc"] = "滑動以改變按鍵數量"
L["number_of_reasons_desc"] = "滑動以改變理由數量"
L["Observe"] = "觀察"
L["observe_desc"] = "如果開啟, 非可拾取成員可以看到分配介面, 但他們不能投票"
L["Offline or RCLootCouncil not installed"] = "離線/沒有安裝插件"
L["Offspec/Greed"] = "副天賦/貪婪"
L["Only use in raids"] = "只會在團隊副本中使用"
L["onlyUseInRaids_desc"] = "選取此項目會將RCLootCouncil在隊伍副本中關閉"
L["open"] = "開啓"
L["Open the Loot History"] = "開啟拾取歷史"
L["open_the_loot_history_desc"] = "打開拾取歷史"
L["Opens the synchronizer"] = "開啟同步"
L["opt_addButton_desc"] = "對選擇部位增加新的按鈕群組"
--[[Translation missing --]]
L["opt_autoAddBoEs_desc"] = "Automatically add all BoE (Bind on Equip) items to a session."
--[[Translation missing --]]
L["opt_autoAddBoEs_name"] = "Auto Add BoEs"
--[[Translation missing --]]
L["opt_autoAddItems_desc"] = "Automatically add all eligible items to a session."
--[[Translation missing --]]
L["opt_autoAddItems_name"] = "Auto Add Items"
--[[Translation missing --]]
L["opt_autoAddPets_desc"] = "Automatically add all Companion Pets to a session."
--[[Translation missing --]]
L["opt_autoAddPets_name"] = "Add Pets"
--[[Translation missing --]]
L["opt_autoAwardPrioList_desc"] = "Items are awarded to the first candidate found in your group according to this priority list."
--[[Translation missing --]]
L["opt_autoGroupLoot_desc"] = "When enabled, RCLootCouncil will automatically click the pass and greed buttons so that all items lands in your inventory."
--[[Translation missing --]]
L["opt_autoGroupLoot_name"] = "Auto Group Loot"
--[[Translation missing --]]
L["opt_autoGroupLootGuildGroupOnly_desc"] = "When enabled, RCLootCouncil will only do group loot auto pass when you're in a guild group."
--[[Translation missing --]]
L["opt_autoGroupLootGuildGroupOnly_name"] = "Guild Groups Only"
--[[Translation missing --]]
L["opt_autoPassWeapons_desc"] = "Check to enable auto passing of weapons your class can't equip."
--[[Translation missing --]]
L["opt_autoPassWeapons_name"] = "Auto Pass Weapons"
--[[Translation missing --]]
L["opt_autoTrade_desc"] = "Check to automatically add awarded items to the trade window when trading with the winner. If disabled, you'll see a popup before items are added."
--[[Translation missing --]]
L["opt_award_later_desc"] = "Check to automatically check the 'Award Later' option in the Session Frame."
--[[Translation missing --]]
L["opt_buttonsGroup_desc"] = [=[Options group for %s buttons and responses.
See above for a detailed explanation.]=]
--[[Translation missing --]]
L["opt_chatFrameName_desc"] = "Select which chat frame you want RCLootCouncil to output information to."
--[[Translation missing --]]
L["opt_chatFrameName_name"] = "Chat Frame"
--[[Translation missing --]]
L["opt_closeWithEscape_desc"] = "When enabled, all non-critical RCLootCouncil frames can be closed by pressing 'Escape'. (Requires reload to take effect on already created frames)"
--[[Translation missing --]]
L["opt_closeWithEscape_name"] = "Escape Close"
L["opt_deleteDate_confirm"] = "你確定你要將比選項舊的紀錄刪除嗎? 刪除後無法復原。"
L["opt_deleteDate_desc"] = "刪除所有比選項中的天數舊的紀錄。"
L["opt_deleteName_confirm"] = "你確定你要刪除所有 %s 的紀錄嗎? 刪除後無法復原。"
--[[Translation missing --]]
L["opt_deleteName_desc"] = "Delete all entries from the selected candidate."
--[[Translation missing --]]
L["opt_deletePatch_confirm"] = [=[Are you sure you want to delete everything older than the selected patch?
 This cannot be undone.]=]
--[[Translation missing --]]
L["opt_deletePatch_desc"] = "Delete all entries added before the selected patch."
--[[Translation missing --]]
L["opt_deleteRaid_confirm"] = [=[Are you sure you want to delete all entries from the selected instance?
This cannot be undone.]=]
--[[Translation missing --]]
L["opt_deleteRaid_desc"] = "Delete all entries from a specific instance."
--[[Translation missing --]]
L["opt_moreButtons_desc"] = "Add a new set of buttons for a specific gear slot. The most specific type is used, i.e. adding buttons for 'Head' and 'Catalyst Items' will make head type armor use the head buttons instead of catalyst."
--[[Translation missing --]]
L["opt_printCompletedTrade_Desc"] = "Check to enable a message every time a candidate trades an awarded item to the winner."
--[[Translation missing --]]
L["opt_printCompletedTrade_Name"] = "Trade Messages"
--[[Translation missing --]]
L["opt_profileSharing_export_desc"] = "Export your current profile."
--[[Translation missing --]]
L["opt_profileSharing_fail_noProfileData"] = "Data is not profile data. Ensure imported data originates from profile export."
--[[Translation missing --]]
L["opt_profileSharing_import_desc"] = "Import a new RCLootCouncil profile. Imports are non-destructive, unless you're overwriting an existing profile."
--[[Translation missing --]]
L["opt_profileSharing_profileExistsWarning"] = "A profile named \"%s\" already exists - do you want to overwrite it?"
--[[Translation missing --]]
L["opt_rejectTrade_Desc"] = "Check to enable candidates to choose whether they want to 'give' the item to the council or not. If unchecked, all tradeable PL items are added automatically."
L["opt_rejectTrade_Name"] = "允許保留裝備"
--[[Translation missing --]]
L["opt_savePersonalLoot_desc"] = "If disabled, personal loot will not be added to the history."
--[[Translation missing --]]
L["opt_savePersonalLoot_name"] = "Record Personal Loot"
--[[Translation missing --]]
L["opt_sharingProfile_success"] = "Succesfully imported profile: \"%s\""
--[[Translation missing --]]
L["opt_skipSessionFrame_desc"] = "Skips the Session Frame. NOTE: This causes the addon to start a session with all eligble items without you having a chance to edit the list!"
--[[Translation missing --]]
L["opt_skipSessionFrame_name"] = "Skip Session Frame"
--[[Translation missing --]]
L["opt_timeoutFlash_desc"] = "When enabled, the loot frame will flash when there's 5 seconds left to the item timeouts."
--[[Translation missing --]]
L["opt_timeoutFlash_name"] = "Timeout Flash"
--[[Translation missing --]]
L["opt_usage_AskGroupLoot"] = "Ask me every time Group Loot is enabled"
--[[Translation missing --]]
L["opt_usage_GroupLoot"] = "Always use RCLootCouncil with Group Loot"
--[[Translation missing --]]
L["opt_useSlashRC_desc"] = "Disable this if you want to restore '/rc' to ready check. RCLootCouncil commands are still available with '/rclc'. A '/reload' is required for this to take effect."
--[[Translation missing --]]
L["opt_useSlashRC_name"] = "Use /rc"
--[[Translation missing --]]
L["options_autoAwardBoE_desc"] = "Enable to automatically award all epic BoE (Bind on Equip) items to a specific person for the selected reason."
--[[Translation missing --]]
L["options_autoAwardBoE_name"] = "Auto Award BoE's"
--[[Translation missing --]]
L["options_ml_outOfRaid_desc"] = "When enabled, while in a group of 8 or more members, anyone that isn't in an instance when a session starts will automatically send an 'Out of Raid' response."
--[[Translation missing --]]
L["options_ml_outOfRaid_name"] = "Out of Raid Support"
--[[Translation missing --]]
L["options_requireNotes_desc"] = "If enabled, candidates cannot submit their response without having entered a note."
--[[Translation missing --]]
L["Original Owner"] = "Original Owner"
L["Out of instance"] = "不在副本內"
--[[Translation missing --]]
L["Patch"] = "Patch"
L["Personal Loot - Non tradeable"] = "個人拾取 - 無法交易"
L["Personal Loot - Rejected Trade"] = "個人拾取 - 拒絕交易"
L["'player' can't receive 'type'"] = "%s無法獲得%s - 版本不同?"
L["'player' declined your sync request"] = "%s拒絕你的同步要求"
L["'player' has asked you to reroll"] = "%s請你重新骰"
L["'player' has ended the session"] = "%s結束了分配"
L["'player' has rolled 'roll' for: 'item'"] = "%s 擲出了 %d： %s"
L["'player' hasn't opened the sync window"] = "%s還沒開啟同步視窗 (/rc sync)"
L["Player is ineligible for this item"] = "玩家不符合此裝備的拾取條件"
L["Player is not in the group"] = "玩家不在隊伍中"
L["Player is not in this instance"] = "玩家不在這個副本內"
L["Player is offline"] = "玩家不在線"
L["Please wait a few seconds until all data has been synchronized."] = "數據同步中，請稍等幾秒。"
L["Please wait before trying to sync again."] = "請稍等一下再嘗試同步。"
L["Print Responses"] = "輸出回應"
L["print_response_desc"] = "在聊天窗口中顯示你的回應"
L["Protector Token"] = "保衛者代幣"
L["Raw lua output. Doesn't work well with date selection."] = "原始lua輸出。不適合日期選擇。"
--[[Translation missing --]]
L["rcframe_help"] = [=[Double click here to minimize
Click and drag to move
Ctrl+scroll to change scale]=]
L["RCLootCouncil - Synchronizer"] = "RCLootCouncil - 同步功能"
L["RCLootCouncil Loot Frame"] = "RCLootCouncil 拾取介面"
L["RCLootCouncil Loot History"] = "RCLootCouncil分裝紀錄"
L["RCLootCouncil Session Setup"] = "RCLootCouncil 分配設定"
L["RCLootCouncil Version Checker"] = "RCLootCouncil 檢查更新"
L["RCLootCouncil Voting Frame"] = "RCLootCouncil 投票介面"
L["rclootcouncil_trade_add_item_confirm"] = "RCLootCouncil檢測到你的背包中有%d個可交易物品被分配給了 %s。你想把這些物品加入交易窗口嗎？"
L["Reannounce ..."] = "再次通知..."
L["Reannounced 'item' to 'target'"] = "已重新通告 %s 給 %s"
L["Reason"] = "理由"
L["reason_desc"] = "自動分配時分配理由將記錄在拾取歷史"
L["Remove All"] = "移除全部"
L["Remove from consideration"] = "從待決定中移除"
L["remove_all_desc"] = "移除所有可拾取成員"
L["Requested rolls for 'item' from 'target'"] = "已要求 %2$s 對 %1$s 擲點"
--[[Translation missing --]]
L["Require Notes"] = "Require Notes"
L["Reset Skin"] = "重置外觀"
L["Reset skins"] = "重置外觀"
L["reset_announce_to_default_desc"] = "重置所有通知選項"
L["reset_buttons_to_default_desc"] = "重置所有按鍵、顏色和回應"
L["reset_skin_desc"] = "重置目前外觀所有顏色及背景"
L["reset_skins_desc"] = "重置預設外觀"
L["reset_to_default_desc"] = "重置分配理由"
L["Response"] = "回應"
L["Response color"] = "回應顏色"
L["Response isn't available. Please upgrade RCLootCouncil."] = "回應不存在。請升級RCLootCouncil。"
L["Response options"] = "回應選項"
L["Response to 'item'"] = "對%s的回應"
L["Response to 'item' acknowledged as 'response'"] = "對%s的回應被認定為\" %s \""
L["response_color_desc"] = "為回應設置一種顏色"
--[[Translation missing --]]
L["response_NOTELIGIBLE"] = "Not eligible for this item"
L["Responses"] = "回應"
L["Responses from Chat"] = "聊天頻道回應"
L["responses_from_chat_desc"] = [=[如果有人沒裝插件，他可以密分裝者 "rchelp" 來得知關鍵字列表
ex: /w 分裝者ID [裝備] 需求]=]
L["Save Skin"] = "存取外觀"
L["save_skin_desc"] = "輸入外觀名稱並點「確定」存取外觀。註解:你可以覆蓋任何非預設的外觀。"
L["Self Vote"] = "自我投票"
L["self_vote_desc"] = "允許投票者投給他自己"
L["Send History"] = "發送歷史"
--[[Translation missing --]]
L["Send to Guild"] = "Send to Guild"
L["send_history_desc"] = "發送數據給隊伍中所有成員。只有你是分裝者RCLootCouncil 才會發送數據"
--[[Translation missing --]]
L["send_to_guild_desc"] = "Send history to guild members instead of your group. Useful if you're running multiple raid groups and want a combined history for your guild. The downside is non-guild members in your group won't register your history entries."
L["Sending 'type' to 'player'..."] = "寄送%s給%s..."
L["Sent whisper help to 'player'"] = "發送密語幫助給%s"
L["session_error"] = "出現了一些錯誤 - 請重新分配"
L["session_help_from_bag"] = "分配結束后，你可以使用命令'/rc winners'查看你應該和誰交易。"
L["session_help_not_direct"] = "此分配會話中的物品不會被直接分配。物品需要被交易。"
L["Set the text for button i's response."] = "設定回應按鈕%d的文字"
L["Set the text on button 'number'"] = "設置按鍵文字%i"
L["Set the whisper keys for button i."] = "設定%d的密語關鍵字"
L["Show Spec Icon"] = "顯示專精圖標"
L["show_spec_icon_desc"] = "選中此項會在接收到專精信息時將候選人的職業圖標替換為專精圖標。"
L["Silent Auto Pass"] = "隱藏自動放棄"
L["silent_auto_pass_desc"] = "隱藏自動放棄信息"
L["Simple BBCode output."] = "簡易BBCode輸出"
L["Skins"] = "外觀"
L["skins_description"] = "選取預設的外觀或者製作你自己的外觀。註解: 這只會影響外觀。打開版本檢查可以馬上看到結果 ('/rc version')。"
L["Slot"] = "部位"
L["Socket"] = "插槽"
L["Something went wrong :'("] = "出現了一些問題 哭哭"
L["Something went wrong during syncing, please try again."] = "同步發生錯誤，請再試一次。"
L["Sort Items"] = "物品排序"
L["sort_items_desc"] = "將物品按照類型與裝等排序。"
L["Standard .csv output."] = "標準.csv輸出格式"
--[[Translation missing --]]
L["Standard JSON output."] = "JSON array containing one JSON object per history entry."
L["Status texts"] = "狀態文字"
--[[Translation missing --]]
L["Stop"] = "Stop"
L["Store in bag and award later"] = "存入背包以稍后分配"
L["Succesfully deleted %d entries"] = "成功刪除 %d 紀錄"
L["Succesfully deleted %d entries from %s"] = "成功從 %s 刪除 %d 紀錄"
L["Successfully imported 'number' entries."] = "成功輸入 %d 紀錄"
L["Successfully received 'type' from 'player'"] = "成溝從%s接收到%s。"
L["Sync"] = "同步"
L["sync_detailed_description"] = [=[1. 雙方都需要開啟同步視窗 (/rc sync)。
2. 選取希望傳送的數據。
3. 選取接收數據的玩家。
4. 點擊「同步」 - 你會看到同步的狀態條。

這個視窗必須開啟才能夠開始同步，但是關掉視窗並不會中止執行中的同步作業。

目標包括上線中的公會及團隊成員，朋友和你當前的友善目標。]=]
--[[Translation missing --]]
L["sync_warning1"] = "Note: Syncing large amounts of data in game can be very slow (especially the loot history)."
--[[Translation missing --]]
L["sync_warning2"] = "Settings and loot history can both be exported/imported as an alternative - see '/rc profile' and/or '/rc history' respectively."
L["test"] = "測試"
L["Test"] = "測試"
L["test_desc"] = "為所有人開啟模擬分配"
L["Text color"] = "文字顏色"
L["Text for reason #i"] = "輸入理由"
L["text_color_desc"] = "文字顯示顏色"
L["The award later list has been cleared."] = "已清空稍后分配列表。"
L["The award later list is empty."] = "稍后分配列表為空。"
L["The following council members have voted"] = "以下的投票成員已投票"
L["The following entries are removed from the award later list:"] = "以下條目已被移除出稍后分配列表"
L["The following items are removed from the award later list and traded to 'player'"] = "以下物品已被移除出稍后分配列表並交易給了 %s"
L["The item can only be looted by you but it is not bind on pick up"] = "這件物品隻能被你拾取，但是這件物品不拾取綁定。"
L["The item will be awarded later"] = "這件物品將會稍后分配"
L["The item would now be awarded to 'player'"] = "這件物品現在將分配給%s"
L["The loot is already on the list"] = "掉落物已經在列表"
L["The loot master"] = "戰利品分配者"
L["The Master Looter doesn't allow multiple votes."] = "分裝者禁用多選投票"
L["The Master Looter doesn't allow votes for yourself."] = "分裝者禁用自我投票"
L["The session has ended."] = "分配已結束"
L["This item"] = "這件物品"
L["This item has been awarded"] = "這件物品已分配"
L["Tier 19"] = "T19"
L["Tier 20"] = "T20"
L["Tier 21"] = "T21"
L["Tier Tokens ..."] = "套裝代幣"
L["Tier tokens received from here:"] = "從這邊獲得的套裝代幣:"
L["tier_token_heroic"] = "英雄"
L["tier_token_mythic"] = "傳奇"
L["tier_token_normal"] = "普通"
L["Time"] = "時間"
L["time_remaining_warning"] = "警告 - 以下在你包包中的裝備在 %d 分鐘後將無法交易: "
L["Timeout"] = "時間已到"
L["Timeout when giving 'item' to 'player'"] = "將%s分配給 %s 時超時"
L["To target"] = "向目標"
L["Tokens received"] = "獲得代幣"
L["Total awards"] = "總共獎勵"
L["Total items received:"] = "總共獲得件數:"
L["Total items won:"] = "總共贏得件數:"
L["trade_complete_message"] = "%s 將 %s 交易給 %s"
L["trade_item_to_trade_not_found"] = "警告: 交易裝備: %s 無法在你的包包中找到!"
L["trade_wrongwinner_message"] = "警告: %s 將 %s 交易給 %s 是錯誤的目標，應該交易給 %s"
L["tVersion_outdated_msg"] = "最新的RCLootCouncil版本是：%s"
L["Unable to give 'item' to 'player'"] = "無法將 %s 分配給 %s"
L["Unable to give 'item' to 'player' - (player offline, left group or instance?)"] = "無法將%s分配給%s"
L["Unable to give out loot without the loot window open."] = "拾取視窗關閉時無法分配"
L["Unawarded"] = "未分配"
L["Unguilded"] = "無公會"
L["Unknown date"] = "日期不明"
L["Unknown/Chest"] = "未知"
--[[Translation missing --]]
L["Unlooted"] = "Unlooted"
L["Unvote"] = "未投票"
L["Upper Quality Limit"] = "最高品質"
L["upper_quality_limit_desc"] = "選擇自動分配時物品的最高品質"
L["Usage"] = "使用"
L["Usage Options"] = "使用項目"
L["Vanquisher Token"] = "鎮壓者代幣"
L["version"] = "版本"
L["Version"] = "版本"
L["Version Check"] = "版本檢查"
L["version_check_desc"] = "開啓版本檢查模組"
L["version_outdated_msg"] = "你的版本%s已經過期。最新版本為%s，請升級你的RCLootCouncil"
L["Vote"] = "投票"
L["Voters"] = "投票者"
L["Votes"] = "投票"
L["Voting options"] = "投票選項"
L["Waiting for response"] = "等待回應"
L["whisper_guide"] = "[RCLootCouncil]: 以數字回覆 [item1] [item2]需求。 請連結該物品(number)會取代的裝備，回覆的方式如下: '1 貪 [item1]'代表你想要貪第一個物品。"
L["whisper_guide2"] = "[RCLootCouncil]: 如果你被成功添加，你將收到一條確認訊息。"
L["whisper_help"] = [=[沒有安裝插件的團員可以使用密語系統
可以密分裝者 "rchelp" 讓他彈出回應列表，而列表可以在"按鈕和回應"選項裡編輯
建議分裝者開啟"通知待決定" 並且密語系統需要使用物品ID
注意: 分裝者必需要安裝插件，否則所有團員的訊息都將無效]=]
L["whisperKey_greed"] = "貪婪, 副天賦, os, 2"
L["whisperKey_minor"] = "小提升, minor, 3"
L["whisperKey_need"] = "需求, 主天賦, ms, 1"
L["Windows reset"] = "視窗重置"
L["winners"] = "贏家"
L["x days"] = "%d天"
L["x out of x have voted"] = "%d/%d已經投票"
L["You are not allowed to see the Voting Frame right now."] = "你現在無法查看投票界面。"
L["You are not in an instance"] = "你不在副本內"
L["You can only auto award items with a quality lower than 'quality' to yourself due to Blizaard restrictions"] = "由於暴雪限制，你只能自動分配低於%s品質的物品給自己"
L["You cannot start an empty session."] = "你無法開始不含任何物品的分配進程。"
L["You cannot use the menu when the session has ended."] = "你無法使用菜單，因為分配已經結束。"
L["You cannot use this command without being the Master Looter"] = "你不能使用這個命令，因為你不是物品分配者"
L["You can't start a loot session while in combat."] = "戰鬥中無法開始分配"
L["You can't start a session before all items are loaded!"] = "在所有物品加載完成前，你不能開始物品分配！"
L["You haven't selected an award reason to use for disenchanting!"] = "還沒有為裝備分解設定一個分配理由。"
L["You haven't set a council! You can edit your council by typing '/rc council'"] = "你還沒有設定議會！你可以輸入'/rc council'來進行編輯。"
L["You must select a target"] = "你已經在進行物品分配了。"
L["Your note:"] = "你的筆記："
L["You're already running a session."] = "你正在進行分配。"

