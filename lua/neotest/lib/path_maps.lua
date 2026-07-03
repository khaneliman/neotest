local M = {}

local function normalise_root(path)
  if not path then
    return
  end
  if vim.endswith(path, package.config:sub(1, 1)) then
    return path:sub(1, -2)
  end
  return path
end

local function map_path(path, maps, from_key, to_key)
  if type(path) ~= "string" or not maps then
    return path
  end

  local best_from
  local best_to
  for _, map in ipairs(maps) do
    local from = normalise_root(map[from_key])
    local to = normalise_root(map[to_key])
    if from and to and (path == from or vim.startswith(path, from .. package.config:sub(1, 1))) then
      if not best_from or #from > #best_from then
        best_from = from
        best_to = to
      end
    end
  end

  if not best_from then
    return path
  end

  return best_to .. path:sub(#best_from + 1)
end

function M.to_remote(path, maps)
  return map_path(path, maps, "local_root", "remote_root")
end

function M.to_local(path, maps)
  return map_path(path, maps, "remote_root", "local_root")
end

function M.map_spec_to_remote(spec, maps)
  if not maps or vim.tbl_isempty(maps) then
    return spec
  end

  if spec.cwd then
    spec.cwd = M.to_remote(spec.cwd, maps)
  end
  if spec.command then
    spec.command = vim.tbl_map(function(value)
      return M.to_remote(value, maps)
    end, spec.command)
  end
  return spec
end

local function map_error_to_local(error, maps)
  if type(error) == "table" and error.path then
    error.path = M.to_local(error.path, maps)
  end
  return error
end

function M.map_results_to_local(results, maps)
  if type(results) ~= "table" or not maps or vim.tbl_isempty(maps) then
    return results
  end

  local mapped = {}
  for pos_id, result in pairs(results) do
    local local_id = M.to_local(pos_id, maps)
    if result.output then
      result.output = M.to_local(result.output, maps)
    end
    if result.errors then
      result.errors = vim.tbl_map(function(error)
        return map_error_to_local(error, maps)
      end, result.errors)
    end
    mapped[local_id] = result
  end
  return mapped
end

return M
