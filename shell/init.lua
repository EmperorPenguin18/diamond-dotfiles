vim.opt = setmetatable({}, {
  __newindex = function(_, key, value)
    if type(value) == "boolean" then
      vim.command("set " .. (value and "" or "no") .. key)
    else
      vim.command("set " .. key .. "=" .. tostring(value))
    end
  end,
  __index = function(_, key)
    return vim.eval("&" .. key)
  end,
})

vim.opt.number = true
vim.opt.relativenumber = true
