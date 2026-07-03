local nio = require("nio")
local a = nio.tests
local stub = require("luassert.stub")
local Watcher = require("neotest.consumers.watch.watcher")
local lib = require("neotest.lib")

describe("watch consumer", function()
  after_each(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end)

  a.it("keeps literal special characters in buffer paths", function()
    local path = vim.loop.cwd()
      .. "/app/routes/_app.segment.articles_.$articleId.$entity.edit.($kind)/routes.test.ts"
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, path)

    assert.equal(path, Watcher._buf_path(buf))
  end)

  a.it("keeps dependency inspection errors scoped to the inspected path", function()
    local watcher = Watcher:new({})
    local path = vim.loop.cwd() .. "/test_file.lua"
    local dependencies = {}
    local notify_stub = stub(lib, "notify")
    local get_linked_files_stub = stub(watcher, "_get_linked_files", function()
      error("missing symbols query")
    end)

    watcher:_build_dependencies(vim.loop.cwd(), { path }, {
      filter_path = function()
        return true
      end,
    }, dependencies)

    assert.same({ [path] = { path } }, dependencies)
    assert.stub(watcher._get_linked_files).was_called()
    assert.stub(lib.notify).was_called()

    get_linked_files_stub:revert()
    notify_stub:revert()
  end)
end)
