--Terrortown settings module for ULX GUI
--默认ines ttt cvar limits and ttt specific settings for the ttt gamemode.

local terrortown_settings = xlib.makepanel{ parent=xgui.null }

xlib.makelabel{ x=5, y=5, w=600, wordwrap=true, label="恐怖镇 ULX 命令 XGUI 模块的问题 由Bender180制作 汉化 by 随波逐流", parent=terrortown_settings }
xlib.makelabel{ x=2, y=345, w=600, wordwrap=true, label="当服务器更改地图,重新启动或崩溃时,以上设置不保存.它们仅供方便访问", parent=terrortown_settings }

xlib.makelabel{ x=5, y=190, w=160, wordwrap=true, label="服务器所有者注意:限制此面板允许或拒绝对 xgui_gmsettings 的权限.", parent=terrortown_settings }
xlib.makelabel{ x=5, y=250, w=160, wordwrap=true, label="列出的所有设置都在此处说明: http://ttt.badking.net/config- and-commands/convars", parent=terrortown_settings }
xlib.makelabel{ x=5, y=325, w=160, wordwrap=true, label="并非所有设置都会回显聊天.", parent=terrortown_settings }


terrortown_settings.panel = xlib.makepanel{ x=160, y=25, w=420, h=318, parent=terrortown_settings }
terrortown_settings.catList = xlib.makelistview{ x=5, y=25, w=150, h=157, parent=terrortown_settings }
terrortown_settings.catList:AddColumn( "恐怖小镇设置" )
terrortown_settings.catList.Columns[1].DoClick = function() end

terrortown_settings.catList.OnRowSelected = function( self, LineID, Line )
	local nPanel = xgui.modules.submodule[Line:GetValue(2)].panel
	if nPanel ~= terrortown_settings.curPanel then
		nPanel:SetZPos( 0 )
		xlib.addToAnimQueue( "pnlSlide", { panel=nPanel, startx=-435, starty=0, endx=0, endy=0, setvisible=true } )
		if terrortown_settings.curPanel then
			terrortown_settings.curPanel:SetZPos( -1 )
			xlib.addToAnimQueue( terrortown_settings.curPanel.SetVisible, terrortown_settings.curPanel, false )
		end
		xlib.animQueue_start()
		terrortown_settings.curPanel = nPanel
	else
		xlib.addToAnimQueue( "pnlSlide", { panel=nPanel, startx=0, starty=0, endx=-435, endy=0, setvisible=false } )
		self:ClearSelection()
		terrortown_settings.curPanel = nil
		xlib.animQueue_start()
	end
	if nPanel.onOpen then nPanel.onOpen() end --If the panel has it, call a function when it's opened
end

--Process modular settings
function terrortown_settings.processModules()
	terrortown_settings.catList:Clear()
	for i, module in ipairs( xgui.modules.submodule ) do
		if module.mtype == "terrortown_settings" and ( not module.access or LocalPlayer():query( module.access ) ) then
			local w,h = module.panel:GetSize()
			if w == h and h == 0 then module.panel:SetSize( 275, 322 ) end
			
			if module.panel.scroll then --For DListLayouts
				module.panel.scroll.panel = module.panel
				module.panel = module.panel.scroll
			end
			module.panel:SetParent( terrortown_settings.panel )
			
			local line = terrortown_settings.catList:AddLine( module.name, i )
			if ( module.panel == terrortown_settings.curPanel ) then
				terrortown_settings.curPanel = nil
				terrortown_settings.catList:SelectItem( line )
			else
				module.panel:SetVisible( false )
			end
		end
	end
	terrortown_settings.catList:SortByColumn( 1, false )
end
terrortown_settings.processModules()

xgui.hookEvent( "onProcessModules", nil, terrortown_settings.processModules )
xgui.addModule( "恐怖小镇服务器设定", terrortown_settings, "icon16/ttt.png", "xgui_gmsettings" )

--------------------Round structure Module--------------------
local rspnl = xlib.makelistlayout{ w=415, h=318, parent=xgui.null }

--Preparation and post-round
local rspapclp = vgui.Create( "DCollapsibleCategory", rspnl ) 
rspapclp:SetSize( 390, 70 )
rspapclp:SetExpanded( 1 )
rspapclp:SetLabel( "准备和赛后" )

local rspaplst = vgui.Create( "DPanelList", rspapclp )
rspaplst:SetPos( 5, 25 )
rspaplst:SetSize( 390, 70 )
rspaplst:SetSpacing( 5 )
   
local prept = xlib.makeslider{ label="准备阶段的时间 (默认. 30)", min=1, max=120, repconvar="rep_ttt_preptime_seconds", parent=rspaplst }
rspaplst:AddItem( prept )

local fprept = xlib.makeslider{ label="第一轮准备阶段的时间 (默认. 60)", min=1, max=120, repconvar="rep_ttt_firstpreptime", parent=rspaplst }
rspaplst:AddItem( fprept )

local pstt = xlib.makeslider{ label="回合结束时间 (默认. 30)", min=1, max=120, repconvar="rep_ttt_posttime_seconds", parent=rspaplst }
rspaplst:AddItem( pstt )

--Round length
local rsrlclp = vgui.Create( "DCollapsibleCategory", rspnl ) 
rsrlclp:SetSize( 390, 90)
rsrlclp:SetExpanded( 0 )
rsrlclp:SetLabel( "回合长度" )

local rsrllst = vgui.Create( "DPanelList", rsrlclp )
rsrllst:SetPos( 5, 25 )
rsrllst:SetSize( 390, 90 )
rsrllst:SetSpacing( 5 )

local hstmd = xlib.makecheckbox{label="急速模式", repconvar="rep_ttt_haste", parent=rsrllst }
rsrllst:AddItem( hstmd )

local hstsm = xlib.makeslider{label="急速模式时间限制 (默认. 5)", min=1, max=60, repconvar="rep_ttt_haste_starting_minutes", parent=rsrllst}
rsrllst:AddItem( hstsm )

local hstmpd = xlib.makeslider{label="每次死亡的回合时间 (默认. 0.5)", min=0.1, max=9, decimal=1, repconvar="rep_ttt_haste_minutes_per_death", parent=rsrllst}
rsrllst:AddItem( hstmpd )

local rtm = xlib.makeslider{label="每轮的时间限制 (默认. 10)", min=1, max=60, repconvar="rep_ttt_roundtime_minutes", parent=rsrllst}
rsrllst:AddItem( rtm )

--Map switching and voting
local msavclp = vgui.Create( "DCollapsibleCategory", rspnl ) 
msavclp:SetSize( 390, 95 )
msavclp:SetExpanded( 0 )
msavclp:SetLabel( "地图切换和投票" )

local msavlst = vgui.Create( "DPanelList", msavclp )
msavlst:SetPos( 5, 25 )
msavlst:SetSize( 390, 95 )
msavlst:SetSpacing( 5 )

local rndl = xlib.makeslider{label="切换地图前的最大回合数 (默认. 6)", min=1, max=100, repconvar="rep_ttt_round_limit", parent=msavlst}
msavlst:AddItem( rndl )

local rndtlm = xlib.makeslider{label="地图切换前的最大分钟数 (默认. 75)", min=1, max=150, repconvar="rep_ttt_time_limit_minutes", parent=msavlst}
msavlst:AddItem( rndtlm )

local rndawm = xlib.makecheckbox{label="投票系统 (默认. 0)", repconvar="rep_ttt_always_use_mapcycle", parent=msavlst }
msavlst:AddItem( rndawm )

local rndawmtxt = xlib.makelabel{ wordwrap=true, label="这什么都不做,但因为它包含在 TTT 中,所以它在这里.", parent=msavlst }
msavlst:AddItem( rndawmtxt )

xgui.hookEvent( "onProcessModules", nil, rspnl.processModules )
xgui.addSubModule( "回合结构", rspnl, nil, "terrortown_settings" )

--------------------Gameplay Module--------------------
local gppnl = xlib.makelistlayout{ w=415, h=318, parent=xgui.null }

--Traitor and Detective counts
local gptdcclp = vgui.Create( "DCollapsibleCategory", gppnl ) 
gptdcclp:SetSize( 390, 100 )
gptdcclp:SetExpanded( 1 )
gptdcclp:SetLabel( "叛徒和侦探计数" )

local gptdlst = vgui.Create( "DPanelList", gptdcclp )
gptdlst:SetPos( 5, 25 )
gptdlst:SetSize( 390, 100 )
gptdlst:SetSpacing( 5 )
   
local tpercet = xlib.makeslider{ label="成为叛徒的玩家总数的百分比 (默认. 0.25)", min=0.01, max=2, decimal=2, repconvar="rep_ttt_traitor_pct", parent=gptdlst}
gptdlst:AddItem( tpercet )

local tmax = xlib.makeslider{ label="叛徒的最大数量 (默认. 32)", min=1, max=80, repconvar="rep_ttt_traitor_max", parent=gptdlst }
gptdlst:AddItem( tmax )

local dpercet = xlib.makeslider{ label="成为侦探的玩家总数的百分比 (默认. 0.13)", min=0.01, max=2, decimal=2, repconvar="rep_ttt_detective_pct", parent=gptdlst }
gptdlst:AddItem( dpercet )

local dmax = xlib.makeslider{ label="侦探的最大数量 (默认. 32)", min=1, max=80, repconvar="rep_ttt_detective_max", parent=gptdlst }
gptdlst:AddItem( dmax )

local dmp = xlib.makeslider{ label="成为侦探最少玩家人数 (默认. 10)", min=1, max=50, repconvar="rep_ttt_detective_min_players", parent=gptdlst }
gptdlst:AddItem( dmp )

local dkm = xlib.makeslider{ label="成为探长最低业力值 (默认. 600)", min=1, max=1000, repconvar="rep_ttt_detective_karma_min", parent=gptdlst }
gptdlst:AddItem( dkm )

--DNA
local gpdnaclp = vgui.Create( "DCollapsibleCategory", gppnl ) 
gpdnaclp:SetSize( 390, 45 )
gpdnaclp:SetExpanded( 0 )
gpdnaclp:SetLabel( "DNA" )

local gpdnalst = vgui.Create( "DPanelList", gpdnaclp )
gpdnalst:SetPos( 5, 25 )
gpdnalst:SetSize( 390, 45 )
gpdnalst:SetSpacing( 5 )

local dnarange = xlib.makeslider{ label="杀手的DNA最大范围 (默认. 550)", min=100, max=1000, repconvar="rep_ttt_killer_dna_range", parent=gpdnalst }
gpdnalst:AddItem( dnarange )

local dnakbt = xlib.makeslider{ label="杀手的DNA样本时间  (默认. 100)", min=10, max=200, repconvar="rep_ttt_killer_dna_basetime", parent=gpdnalst }
gpdnalst:AddItem( dnakbt )

--Voicechat battery
local gpvcbclp = vgui.Create( "DCollapsibleCategory", gppnl ) 
gpvcbclp:SetSize( 390, 65)
gpvcbclp:SetExpanded( 0 )
gpvcbclp:SetLabel( "语音聊天电池" )

local gpvcblst = vgui.Create( "DPanelList", gpvcbclp )
gpvcblst:SetPos( 5, 25 )
gpvcblst:SetSize( 390, 65 )
gpvcblst:SetSpacing( 5 )

local gpevd = xlib.makecheckbox{label="语音聊天电池功能 (默认. 0)", repconvar="rep_ttt_voice_drain", parent=gpvcblst }
gpvcblst:AddItem( gpevd )

local gpvdn = xlib.makeslider{ label="消耗电池电量 (默认. 0.2)", min=0.1, max=1, decimal=1, repconvar="rep_ttt_voice_drain_normal", parent=gpvcblst }
gpvcblst:AddItem( gpvdn )

local gpvda = xlib.makeslider{ label="管理员和侦探的电池消耗 (默认. 0.05)", min=0.01, max=1, decimal=2, repconvar="rep_ttt_voice_drain_admin", parent=gpvcblst }
gpvcblst:AddItem( gpvda )

local gpvdr = xlib.makeslider{ label="电池充电率 (默认. 0.05)", min=0.01, max=1, decimal=2, repconvar="rep_ttt_voice_drain_recharge", parent=gpvcblst }
gpvcblst:AddItem( gpvdr )

--Other gameplay settings
local gpogsclp = vgui.Create( "DCollapsibleCategory", gppnl ) 
gpogsclp:SetSize( 390, 200)
gpogsclp:SetExpanded( 0 )
gpogsclp:SetLabel( "其他游戏设置" )

local gpogslst = vgui.Create( "DPanelList", gpogsclp )
gpogslst:SetPos( 5, 25 )
gpogslst:SetSize( 390, 200 )
gpogslst:SetSpacing( 5 )

local gpminply = xlib.makeslider{label="玩家人数 (默认. 2)", min=1, max=10, repconvar="rep_ttt_minimum_players", parent=gpogslst }
gpogslst:AddItem( gpminply )

local gpprdm = xlib.makecheckbox{ label="回合结束启用伤害 (默认. 0)", repconvar="rep_ttt_postround_dm", parent=gpogslst }
gpogslst:AddItem( gpprdm )

local gpds = xlib.makecheckbox{ label="垂死挣扎 (默认. 0)", repconvar="rep_ttt_dyingshot", parent=gpogslst }
gpogslst:AddItem( gpds )

local gpnntdp = xlib.makecheckbox{ label="准备阶段投掷手榴弹 (默认. 0)", repconvar="rep_ttt_no_nade_throw_during_prep", parent=gpogslst }
gpogslst:AddItem( gpnntdp )

local gpwc = xlib.makecheckbox{ label="使用磁棒携带武器 (默认. 1)", repconvar="rep_ttt_weapon_carrying", parent=gpogslst }
gpogslst:AddItem( gpwc )

local gpwcr = xlib.makeslider{label="拿起武器携带磁棒的范围 (默认. 50)", min=10, max=100, repconvar="rep_ttt_weapon_carrying_range", parent=gpogslst }
gpogslst:AddItem( gpwcr )

local gpttf = xlib.makecheckbox{ label="杀死站在传送目的地的玩家 (默认. 0)", repconvar="rep_ttt_teleport_telefrags", parent=gpogslst }
gpogslst:AddItem( gpttf )

local gprdp = xlib.makecheckbox{ label="使用磁棒将尸体钉在墙上 (默认. 1)", repconvar="rep_ttt_ragdoll_pinning", parent=gpogslst }
gpogslst:AddItem( gprdp )

local gprdpi = xlib.makecheckbox{ label="非叛徒玩家可以钉死尸体 (默认. 0)", repconvar="rep_ttt_ragdoll_pinning_innocents", parent=gpogslst }
gpogslst:AddItem( gprdpi )

xgui.hookEvent( "onProcessModules", nil, gppnl.processModules )
xgui.addSubModule( "游戏玩法", gppnl, nil, "terrortown_settings" )

--------------------Karma Module--------------------
local krmpnl = xlib.makelistlayout{ w=415, h=318, parent=xgui.null }

local krmclp = vgui.Create( "DCollapsibleCategory", krmpnl ) 
krmclp:SetSize( 390, 400)
krmclp:SetExpanded( 1 )
krmclp:SetLabel( "业余值" )

local krmlst = vgui.Create( "DPanelList", krmclp )
krmlst:SetPos( 5, 25 )
krmlst:SetSize( 390, 400 )
krmlst:SetSpacing( 5 )

local krmekrm = xlib.makecheckbox{label="业力系统", repconvar="rep_ttt_karma", parent=krmlst }
krmlst:AddItem( krmekrm )

local krmeskrm = xlib.makecheckbox{ label="伤害惩罚系统", repconvar="rep_ttt_karma_strict", parent=krmlst }
krmlst:AddItem( krmeskrm )

local krms = xlib.makeslider{ label="业力值初始值 (默认. 1000)", min=500, max=2000, repconvar="rep_ttt_karma_starting", parent=krmlst }
krmlst:AddItem( krms )

local krmmx = xlib.makeslider{ label="最大业力值 (默认. 1000)", min=500, max=2000, repconvar="rep_ttt_karma_max", parent=krmlst }
krmlst:AddItem( krmmx )

local krmr = xlib.makeslider{ label="业力值损害比率设置 (默认. 0.001)", min=0.001, max=0.009, decimal=3, repconvar="rep_ttt_karma_ratio", parent=krmlst }
krmlst:AddItem( krmr )

local krmkp = xlib.makeslider{ label="杀戮惩罚 (默认. 15)", min=1, max=30, repconvar="rep_ttt_karma_kill_penalty", parent=krmlst }
krmlst:AddItem( krmkp )

local krmri = xlib.makeslider{ label="每轮结束基础数量 (默认. 5)", min=1, max=30, repconvar="rep_ttt_karma_round_increment", parent=krmlst }
krmlst:AddItem( krmri )

local krmcb = xlib.makeslider{ label="额外治愈 (默认. 30)", min=10, max=100, repconvar="rep_ttt_karma_clean_bonus", parent=krmlst }
krmlst:AddItem( krmcb )

local krmtdmgr = xlib.makeslider{ label="伤害叛徒的业力奖励 (默认. 0.0003)", min=0.0001, max=0.001, decimal=4, repconvar="rep_ttt_karma_traitordmg_ratio", parent=krmlst }
krmlst:AddItem( krmtdmgr )

local krmtkb = xlib.makeslider{ label="杀死叛徒的额外业力 (默认. 40)", min=10, max=100, repconvar="rep_ttt_karma_traitorkill_bonus", parent=krmlst }
krmlst:AddItem( krmtkb )

local krmlak = xlib.makecheckbox{label="回合结束时自动踢出低业力等级的玩家 (默认. 1)", repconvar="rep_ttt_karma_low_autokick", parent=krmlst }
krmlst:AddItem( krmlak)

local krmla = xlib.makeslider{ label="玩家被踢的业力阈值 (默认. 450)", min=100, max=1000, repconvar="rep_ttt_karma_low_amount", parent=krmlst }
krmlst:AddItem( krmla )

local krmlab = xlib.makecheckbox{label="低业力值封禁 (默认. 1)", repconvar="rep_ttt_karma_low_ban", parent=krmlst }
krmlst:AddItem( krmlab)

local krmlbm = xlib.makeslider{ label="封禁业力值最低的玩家时间 (默认. 60)", min=10, max=100, repconvar="rep_ttt_karma_low_ban_minutes", parent=krmlst }
krmlst:AddItem( krmlbm )

local krmpre = xlib.makecheckbox{label="业力值持久存储 (默认. 0)", repconvar="rep_ttt_karma_persist", parent=krmlst }
krmlst:AddItem( krmpre)

local krmdbs = xlib.makecheckbox{label="调试业力变化到控制台 (默认. 0)", repconvar="rep_ttt_karma_debugspam", parent=krmlst }
krmlst:AddItem( krmdbs)

local krmch = xlib.makeslider{ label="业力起始水平 (默认. 0.25)", min=0.01, max=0.9, decimal=2, repconvar="rep_ttt_karma_clean_half", parent=krmlst }
krmlst:AddItem( krmch )

xgui.hookEvent( "onProcessModules", nil, krmpnl.processModules )
xgui.addSubModule( "业余值", krmpnl, nil, "terrortown_settings" )

--------------------Map-related Module--------------------
local mprpnl = xlib.makepanel{ w=415, h=318, parent=xgui.null }

xlib.makecheckbox{x=5, y=5, label="切换是否使用武器脚本 (默认. 1)", repconvar="rep_ttt_use_weapon_spawn_scripts", parent=mprpnl }

xgui.hookEvent( "onProcessModules", nil, mprpnl.processModules )
xgui.addSubModule( "地图相关", mprpnl, nil, "terrortown_settings" )

--------------------Equipment credits Module--------------------
local ecpnl = xlib.makelistlayout{ w=415, h=318, parent=xgui.null }

--Traitor credits
local ectcclp = vgui.Create( "DCollapsibleCategory", ecpnl ) 
ectcclp:SetSize( 390, 120)
ectcclp:SetExpanded( 1 )
ectcclp:SetLabel( "叛徒学分" )

local ectclst = vgui.Create( "DPanelList", ectcclp )
ectclst:SetPos( 5, 25 )
ectclst:SetSize( 390, 120 )
ectclst:SetSpacing( 5 )

local ectccs = xlib.makeslider{ label="初始学分数量 (默认. 2)", min=0, max=10, repconvar="rep_ttt_credits_starting", parent=ectclst }
ectclst:AddItem( ectccs )

local ectcap = xlib.makeslider{ label="百分比的无辜玩家死亡获得学分 (默认. 0.35)", min=0.01, max=0.9, decimal=2, repconvar="rep_ttt_credits_award_pct", parent=krmlst }
ectclst:AddItem( ectcap )

local ectcas = xlib.makeslider{ label="授予的学分数量 (默认. 1)", min=0, max=5, repconvar="rep_ttt_credits_award_size", parent=ectclst }
ectclst:AddItem( ectcas )

local ectcar = xlib.makeslider{ label="发放学分奖励数量 (默认. 1)", min=0, max=5, repconvar="rep_ttt_credits_award_repeat", parent=ectclst }
ectclst:AddItem( ectcar )

local ectcdk = xlib.makeslider{ label="叛徒杀死侦探玩家时获得的学分点数 (默认. 1)", min=0, max=5, repconvar="rep_ttt_credits_detectivekill", parent=ectclst }
ectclst:AddItem( ectcdk )

--Detective credits
local ecdcclp = vgui.Create( "DCollapsibleCategory", ecpnl ) 
ecdcclp:SetSize( 390, 90)
ecdcclp:SetExpanded( 0 )
ecdcclp:SetLabel( "侦探学分" )

local ecdclst = vgui.Create( "DPanelList", ecdcclp )
ecdclst:SetPos( 5, 25 )
ecdclst:SetSize( 390, 90 )
ecdclst:SetSpacing( 5 )

local ecdccs = xlib.makeslider{ label="探长初始学分 (默认. 1)", min=0, max=10, repconvar="rep_ttt_det_credits_starting", parent=ecdclst }
ecdclst:AddItem( ecdccs )

local ecdctk = xlib.makeslider{ label="探长杀死叛徒学分 (默认. 0)", min=0, max=10, repconvar="rep_ttt_det_credits_traitorkill", parent=ecdclst }
ecdclst:AddItem( ecdctk )

local ecdctd = xlib.makeslider{ label="叛徒死亡给予学分 (默认. 1)", min=0, max=10, repconvar="rep_ttt_det_credits_traitordead", parent=ecdclst }
ecdclst:AddItem( ecdctd )

xgui.hookEvent( "onProcessModules", nil, ecpnl.processModules )
xgui.addSubModule( "设备积分", ecpnl, nil, "terrortown_settings" )

--------------------Prop possession Module--------------------
local pppnl = xlib.makelistlayout{ w=415, h=318, parent=xgui.null }

local ppclp = vgui.Create( "DCollapsibleCategory", pppnl ) 
ppclp:SetSize( 390, 120)
ppclp:SetExpanded( 1 )
ppclp:SetLabel( "道具占有" )

local pplst = vgui.Create( "DPanelList", ppclp )
pplst:SetPos( 5, 25 )
pplst:SetSize( 390, 120 )
pplst:SetSpacing( 5 )

local ppspc = xlib.makecheckbox{label = "切换观众是否可以拥有道具  (默认. 1)", repconvar = "rep_ttt_spec_prop_control", parent = pplst}
pplst:AddItem(ppspc)

local ppspb = xlib.makeslider{label = "道具拳数 (默认. 8)", min = 0, max = 50, repconvar = "rep_ttt_spec_prop_base", parent = pplst}
pplst:AddItem(ppspb)

local ppspmp = xlib.makeslider{label = "负分的冲头限制的最大减少 (默认. -6)", min = -50, max = 0, repconvar = "rep_ttt_spec_prop_maxpenalty", parent = pplst}
pplst:AddItem(ppspmp)

local ppspmb = xlib.makeslider{label = "正分的打孔计限制的最大增加 (默认. 16)", min = 0, max = 50, repconvar = "rep_ttt_spec_prop_maxbonus", parent = pplst}
pplst:AddItem(ppspmb)

local ppspf = xlib.makeslider{label = "每次冲头移动道具的力的大小 (默认. 110)", min = 50, max = 300, repconvar = "rep_ttt_spec_prop_force", parent = pplst}
pplst:AddItem(ppspf)

local ppprt = xlib.makeslider{label = "打孔计中一个点充电的秒数 (默认. 1)", min = 0, max = 10, repconvar = "rep_ttt_spec_prop_rechargetime", parent = pplst}
pplst:AddItem(ppprt)

xgui.hookEvent( "onProcessModules", nil, pppnl.processModules )
xgui.addSubModule( "道具占有", pppnl, nil, "terrortown_settings" )

--------------------Admin-related Module--------------------
local arpnl = xlib.makelistlayout{ w=415, h=318, parent=xgui.null }

local arclp = vgui.Create( "DCollapsibleCategory", arpnl ) 
arclp:SetSize( 390, 120)
arclp:SetExpanded( 1 )
arclp:SetLabel( "管理员相关" )

local arlst = vgui.Create( "DPanelList", arclp )
arlst:SetPos( 5, 25 )
arlst:SetSize( 390, 120 )
arlst:SetSpacing( 5 )

local aril = xlib.makeslider{label="空闲的时间(以秒为单位) (默认. 180)", min=50, max=300, repconvar="rep_ttt_idle_limit", parent=arlst }
arlst:AddItem( aril )

local arnck = xlib.makecheckbox{label="是否自动踢出更改名称的玩家 (默认. 1)", repconvar="rep_ttt_namechange_kick", parent=arlst }
arlst:AddItem( arnck )

local arncbt = xlib.makeslider{label="封禁更改姓名的玩家的时间 (默认. 10)", min=0, max=60, repconvar="rep_ttt_namechange_bantime", parent=arlst }
arlst:AddItem( arncbt )

xgui.hookEvent( "onProcessModules", nil, arpnl.processModules )
xgui.addSubModule( "管理员相关", arpnl, nil, "terrortown_settings" )

--------------------Miscellaneous Module--------------------
local miscpnl = xlib.makelistlayout{ w=415, h=318, parent=xgui.null }

local miscclp = vgui.Create( "DCollapsibleCategory", miscpnl ) 
miscclp:SetSize( 390, 120)
miscclp:SetExpanded( 1 )
miscclp:SetLabel( "各种各样的" )

local misclst = vgui.Create( "DPanelList", miscclp)
misclst:SetPos( 5, 25 )
misclst:SetSize( 390, 120 )
misclst:SetSpacing( 5 )

local miscdh = xlib.makecheckbox{label="探长特殊的帽子 (默认. 0)", repconvar="rep_ttt_detective_hats", parent=misclst }
misclst:AddItem( miscdh )

local miscpcm = xlib.makeslider{label="玩家着色模式 (默认. 1)", min=0, max=3, repconvar="rep_ttt_playercolor_mode", parent=misclst }
misclst:AddItem( miscpcm )

local miscrc = xlib.makecheckbox{label="布娃娃碰撞 (默认. 0)", repconvar="rep_ttt_ragdoll_collide", parent=misclst }
misclst:AddItem( miscrc )

local miscbs = xlib.makecheckbox{label="机器人作为旁观者 (默认. 0)", repconvar="rep_ttt_bots_are_spectators", parent=misclst }
misclst:AddItem( miscbs )

local miscdm = xlib.makecheckbox{label="防止回合结束 (默认. 0)", repconvar="rep_ttt_debug_preventwin", parent=misclst }
misclst:AddItem( miscdm )

local misclv = xlib.makecheckbox{label="切换位置 3D 语音聊天 (默认. 0)", repconvar="rep_ttt_locational_voice", parent=misclst }
misclst:AddItem( misclv )

local miscdj = xlib.makecheckbox{label="启用使分解器推力 (默认. 0)", repconvar="rep_ttt_allow_discomb_jump", parent=misclst }
misclst:AddItem( miscdj )

local miscswi = xlib.makeslider{label="生成所有玩家 (默认. 0)", min=0, max=30, repconvar="rep_ttt_spawn_wave_interval", parent=misclst }
misclst:AddItem( miscswi )

xgui.hookEvent( "onProcessModules", nil, miscpnl.processModules )
xgui.addSubModule( "各种各样的", miscpnl, nil, "terrortown_settings" )