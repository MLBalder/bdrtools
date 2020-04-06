--[[

How to use:

require "bdr_gmui.lua"
function init()
	--make a new menu
	--Caution: building a menu will delete every existing GMFunction existing in your current game
	--You can build a menu 
	menu = Gmui.Menu:new(true)
	
	--menu:getTree(0) > get
	--menu:getTree(0)(0) > get first child node of the root node
	--node:setMenu(MenuNode) > add a menuNode (a button) to the menu
	--menuNode:setTitle() > set the title (the button label) for the menuNode
	--menuNode:setAction() > set the action (must be a callback function) for the menuNode
	--LEAF AND BRANCH
	--if a menuNode has an action, it will be treated as a leaf. Click on leaves trigger the callback
	--if a menuNode has no action, it will be treated as a branch. Click on branches will display the menu containing the children of this node
	menu:getTree(0)(0):setMenu(Gmui.MenuNode:new():setTitle("sub1"))
	menu:getTree(0)(0)(0):setMenu(Gmui.MenuNode:new():setTitle("sub1-1"))
	menu:getTree(0)(0)(1):setMenu(Gmui.MenuNode:new():setTitle("sub1-2"):setAction(foo("action1-2")))
	menu:getTree(0)(1):setMenu(Gmui.MenuNode:new():setTitle("jump to 1-1"):setAction(function()
		--display menu at a specific node
		menu:showSubTree(menu:getTree(0)(0)(0))
	end))
	--build menu from root node
	menu:build()
--]]

--imports
--https://github.com/Kadoba/love-struct
require "libs/love-struct/tree.lua"


function Tree:setMenu(menuNode)
	self:set(menuNode)
	menuNode:setTreeNode(self)
end

--create menu class (represent the menu structure as a whole)
local Menu = {}
Menu.__index = Menu

--constructor
function Menu:new(showBackToRoot)
	print("creating menu")
	local menu = setmetatable({},Menu)
	menu.showBackToRoot = showBackToRoot
	menu.tree = Tree:new()
	return menu
end

--generate the menu from internal tree root
function Menu:build()
	print("building tree")
	self:showSubTree(self.tree)
end

--generate a menu state from a specific node
function Menu:showSubTree(node)
	print("building subtree")
	print(node)
	print(#node)
	clearGMFunctions()
	if(self.showBackToRoot and node and node:get())then
		addGMFunction("/root - current: " .. node:get():getTitle(), function() self:build() end)
	end
	if(node and node:get() and node.parent)then
		print("back btn")
		addGMFunction("../".. node:get():getTitle(), function()
			self:showSubTree(node.parent)
		end)
	end
	if(node)then
		for i=0, #node do
		print("building node " .. i .. " out of " .. (#node+1))
			local nodedata = node[i]:get()
			print(node[i].parent)
			if(nodedata)then
				if(nodedata:isLeaf())then
					print("making leaf")
					print(nodedata:getTitle())
					addGMFunction(nodedata:getTitle(), function()
						print(nodedata:getTitle())
						nodedata:getAction()()
					end)
				else
					print("making branch")
					print(nodedata:getTitle())
					addGMFunction("./"..nodedata:getTitle(), function()
						print(nodedata:getTitle())
						self:showSubTree(nodedata:getTreeNode())
					end)
				end
			end
		end
	end
end

--getters
function Menu:getTree()
	return self.tree
end


-- MenuNode class (represent a button)
local MenuNode = {}
MenuNode.__index = MenuNode

function MenuNode:new(title, action, treeNode)
	local menuNode = setmetatable({},MenuNode)
	menuNode.title = title
	menuNode.action = action
	menuNode.treeNode = treeNode
	return menuNode
end
	
function MenuNode:getTitle()
	return self.title
end
	
function MenuNode:isLeaf()
	if  type(self:getAction()) == "function" then
		print("action")
		print(self:getTitle())
		return true
	else 
		print("not leaf")
		print(self:getTitle())
		return false
	end
end

function MenuNode:getTreeNode()
	return self.treeNode
end

function MenuNode:getAction()
	return self.action
end
	
function MenuNode:getParentTreeNode()
	-- LUA no support for partial evaluation?
	if(self:getTreeNode() and self:getTreeNode().parent) then
		return  self:getTreeNode().parent
	else
		return nil
	end
end

function MenuNode:setTreeNode(treeNode)
	self.treeNode = treeNode
	return self
end

function MenuNode:setTitle(title)
	self.title = title
	return self
end

function MenuNode:setAction(action)
	self.action = action
	return self
end

Gmui = {}
Gmui.Menu = Menu
Gmui.MenuNode = MenuNode
	
print( "bdr_gmui.lua has been loaded" )
	
return Gmui