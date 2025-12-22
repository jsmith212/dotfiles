-- Find clangd-docker script by walking up from a given path
local function find_clangd_docker_from(start_path)
  local dir = start_path
  while dir ~= "/" and dir ~= "" do
    local script = dir .. "/scripts/clangd-docker"
    if vim.fn.filereadable(script) == 1 then
      return script
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return nil
end

-- Try to find from current buffer's directory, fallback to cwd
local function find_clangd_docker()
  local bufpath = vim.api.nvim_buf_get_name(0)
  if bufpath and bufpath ~= "" then
    local bufdir = vim.fn.fnamemodify(bufpath, ":h")
    local script = find_clangd_docker_from(bufdir)
    if script then
      return script
    end
  end
  -- Fallback to cwd
  return find_clangd_docker_from(vim.fn.getcwd())
end

return {
  find_clangd_docker = find_clangd_docker,
  find_clangd_docker_from = find_clangd_docker_from,
}
