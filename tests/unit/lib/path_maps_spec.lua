local path_maps = require("neotest.lib.path_maps")

describe("path maps", function()
  it("maps local paths to remote paths using the longest prefix", function()
    local maps = {
      { local_root = "/workspace", remote_root = "/app" },
      { local_root = "/workspace/pkg", remote_root = "/srv/pkg" },
    }

    assert.equal("/srv/pkg/test.lua", path_maps.to_remote("/workspace/pkg/test.lua", maps))
  end)

  it("maps remote paths to local paths", function()
    local maps = {
      { local_root = "/workspace", remote_root = "/app" },
    }

    assert.equal("/workspace/test.lua::test_a", path_maps.to_local("/app/test.lua::test_a", maps))
  end)

  it("leaves unmapped paths unchanged", function()
    local maps = {
      { local_root = "/workspace", remote_root = "/app" },
    }

    assert.equal("/other/test.lua", path_maps.to_remote("/other/test.lua", maps))
  end)
end)
