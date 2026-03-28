param(
    [string]$BaseUrl = "http://localhost:5071",
    [switch]$AutoStart,
    [string]$ProjectPath = "ToDoList/HoangRESTFul.csproj",
    [int]$StartupTimeoutSeconds = 45
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:Passed = 0
$script:Failed = 0
$script:Results = New-Object System.Collections.Generic.List[object]
$serverProcess = $null

function Add-Result {
    param(
        [string]$Name,
        [bool]$Success,
        [string]$Message
    )

    if ($Success) { $script:Passed++ } else { $script:Failed++ }

    $script:Results.Add([pscustomobject]@{
        Step = $Name
        Success = $Success
        Message = $Message
    }) | Out-Null

    if ($Success) {
        Write-Host "[PASS] $Name - $Message" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $Name - $Message" -ForegroundColor Red
    }
}

function Ensure-ServerReady {
    param(
        [string]$SwaggerUrl,
        [int]$TimeoutSeconds
    )

    $start = Get-Date
    while (((Get-Date) - $start).TotalSeconds -lt $TimeoutSeconds) {
        try {
            $null = Invoke-RestMethod -Method Get -Uri $SwaggerUrl -TimeoutSec 4
            return $true
        } catch {
            Start-Sleep -Milliseconds 1200
        }
    }

    return $false
}

function Invoke-Api {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Path,
        [object]$Body,
        [string]$Token,
        [int[]]$ExpectedStatus
    )

    $headers = @{}
    if ($Token) {
        $headers["Authorization"] = "Bearer $Token"
    }

    $uri = "$BaseUrl$Path"

    try {
        $params = @{
            Method = $Method
            Uri = $uri
            Headers = $headers
            TimeoutSec = 15
            UseBasicParsing = $true
        }

        if ($null -ne $Body) {
            $params["ContentType"] = "application/json"
            $params["Body"] = ($Body | ConvertTo-Json -Depth 8)
        }

        $response = Invoke-WebRequest @params
        $statusCode = [int]$response.StatusCode

        if ($ExpectedStatus -contains $statusCode) {
            $payload = $null
            if ($response.Content) {
                try { $payload = $response.Content | ConvertFrom-Json } catch { $payload = $response.Content }
            }
            Add-Result -Name $Name -Success $true -Message "HTTP $statusCode"
            return [pscustomobject]@{ StatusCode = $statusCode; Body = $payload }
        }

        Add-Result -Name $Name -Success $false -Message "Unexpected HTTP $statusCode"
        return $null
    } catch {
        $statusCode = -1
        $errBody = ""

        if ($_.Exception.Response) {
            try {
                $statusCode = [int]$_.Exception.Response.StatusCode
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $errBody = $reader.ReadToEnd()
            } catch {
                $errBody = $_.Exception.Message
            }
        } else {
            $errBody = $_.Exception.Message
        }

        if ($ExpectedStatus -contains $statusCode) {
            $payload = $null
            if ($errBody) {
                try { $payload = $errBody | ConvertFrom-Json } catch { $payload = $errBody }
            }
            Add-Result -Name $Name -Success $true -Message "HTTP $statusCode"
            return [pscustomobject]@{ StatusCode = $statusCode; Body = $payload }
        }

        Add-Result -Name $Name -Success $false -Message "HTTP $statusCode - $errBody"
        return $null
    }
}

try {
    if ($AutoStart) {
        Write-Host "Starting API server..." -ForegroundColor Cyan
        $serverProcess = Start-Process -FilePath "dotnet" -ArgumentList @("run", "--project", $ProjectPath) -PassThru -WindowStyle Hidden

        $ready = Ensure-ServerReady -SwaggerUrl "$BaseUrl/swagger/v1/swagger.json" -TimeoutSeconds $StartupTimeoutSeconds
        if (-not $ready) {
            Add-Result -Name "Server startup" -Success $false -Message "Server is not ready after $StartupTimeoutSeconds seconds"
            throw "Server not ready"
        }

        Add-Result -Name "Server startup" -Success $true -Message "Server is ready"
    }

    $seed = (Get-Date).ToString("yyyyMMddHHmmss")
    $registerBody = @{
        userName = "apitest_$seed"
        email = "apitest_$seed@example.com"
        password = "Aa123456!"
        fullName = "API Test User"
    }

    $register = Invoke-Api -Name "Register" -Method "POST" -Path "/api/user/register" -Body $registerBody -Token $null -ExpectedStatus @(200, 400)
    if (-not $register) { throw "Cannot continue without register result" }

    $loginBody = @{
        account = $registerBody.userName
        password = $registerBody.password
    }
    $login = Invoke-Api -Name "Login" -Method "POST" -Path "/api/user/login" -Body $loginBody -Token $null -ExpectedStatus @(200)
    if (-not $login -or -not $login.Body.token) { throw "Cannot continue without token" }

    $token = [string]$login.Body.token

    $null = Invoke-Api -Name "Get profile" -Method "GET" -Path "/api/user/profile" -Body $null -Token $token -ExpectedStatus @(200)

    $profileUpdate = @{
        fullName = "API Test User Updated"
        avatarUrl = "https://example.com/avatar.png"
    }
    $null = Invoke-Api -Name "Update profile" -Method "PUT" -Path "/api/user/profile" -Body $profileUpdate -Token $token -ExpectedStatus @(200)

    $createCategoryBody = @{
        name = "Work"
        icon = "briefcase"
        colorHex = "#3B82F6"
    }
    $createCategory = Invoke-Api -Name "Create category" -Method "POST" -Path "/api/category/category" -Body $createCategoryBody -Token $token -ExpectedStatus @(200)
    if (-not $createCategory -or -not $createCategory.Body.id) { throw "Cannot continue without category id" }
    $categoryId = [string]$createCategory.Body.id

    $null = Invoke-Api -Name "Get categories" -Method "GET" -Path "/api/category/category" -Body $null -Token $token -ExpectedStatus @(200)

    $updateCategoryBody = @{
        name = "Work Updated"
        icon = "work"
        colorHex = "#10B981"
    }
    $null = Invoke-Api -Name "Update category" -Method "PUT" -Path "/api/category/category/$categoryId" -Body $updateCategoryBody -Token $token -ExpectedStatus @(200)

    $dueDate = (Get-Date).AddDays(2).ToString("o")
    $createTodoBody = @{
        title = "Write API tests"
        description = "Create and verify all todo features"
        priority = 2
        dueDate = $dueDate
        categoryId = $categoryId
    }
    $createTodo = Invoke-Api -Name "Create todo" -Method "POST" -Path "/api/todo/addtodo" -Body $createTodoBody -Token $token -ExpectedStatus @(200)
    if (-not $createTodo -or -not $createTodo.Body.id) { throw "Cannot continue without todo id" }
    $todoId = [string]$createTodo.Body.id

    $null = Invoke-Api -Name "Get todo detail" -Method "GET" -Path "/api/todo/detail/$todoId" -Body $null -Token $token -ExpectedStatus @(200)

    $updateTodoBody = @{
        title = "Write API tests - updated"
        description = "Updated description"
        priority = 1
        dueDate = (Get-Date).AddDays(3).ToString("o")
        categoryId = $categoryId
        isCompleted = $false
    }
    $null = Invoke-Api -Name "Update todo full" -Method "PUT" -Path "/api/todo/updatetodo/$todoId" -Body $updateTodoBody -Token $token -ExpectedStatus @(200)

    $queryPath = "/api/todo/usertodo?isCompleted=false&priority=1&page=1&pageSize=10&keyword=updated&sortBy=createdAt&sortOrder=desc"
    $null = Invoke-Api -Name "List todos with filter/sort/pagination" -Method "GET" -Path $queryPath -Body $null -Token $token -ExpectedStatus @(200)

    $null = Invoke-Api -Name "Todo stats" -Method "GET" -Path "/api/todo/stats" -Body $null -Token $token -ExpectedStatus @(200)

    $null = Invoke-Api -Name "Toggle todo status" -Method "PUT" -Path "/api/todo/updatestatus/$todoId" -Body $null -Token $token -ExpectedStatus @(200)

    $null = Invoke-Api -Name "Delete todo" -Method "DELETE" -Path "/api/todo/deletetodo/$todoId" -Body $null -Token $token -ExpectedStatus @(200)

    $null = Invoke-Api -Name "Delete category" -Method "DELETE" -Path "/api/category/category/$categoryId" -Body $null -Token $token -ExpectedStatus @(200)
}
catch {
    Add-Result -Name "Run aborted" -Success $false -Message $_.Exception.Message
}
finally {
    if ($serverProcess -and -not $serverProcess.HasExited) {
        Write-Host "Stopping API server..." -ForegroundColor Cyan
        Stop-Process -Id $serverProcess.Id -Force -ErrorAction SilentlyContinue
    }

    Write-Host ""
    Write-Host "================ TEST SUMMARY ================" -ForegroundColor Yellow
    $script:Results | Format-Table -AutoSize
    Write-Host "Passed: $($script:Passed)" -ForegroundColor Green
    Write-Host "Failed: $($script:Failed)" -ForegroundColor Red
    Write-Host "=============================================" -ForegroundColor Yellow

    if ($script:Failed -gt 0) {
        exit 1
    }

    exit 0
}
