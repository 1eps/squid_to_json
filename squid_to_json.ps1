Param (
[string]$logPath = '', ## Параметр определяющий путь к файлу лога.
[string]$outFileName = ''  ## Параметр определяющий имя и место выходного
)

$Array = @(Get-Content $logPath) ##Создаем массив из строк лог файла


Write-Host ("Количество событий в файле лога: " + $Array.Count + ".") ##Считаем количество строк


##Цикл на проверку каждого элемента массива в поиске нужного значения:
foreach ($strArray in $Array) ##Бежим по массиву со строками
{
   $splitArray = @($strArray.split(' ')) ##Разделяю строку на массив с разделителем пробел
   
   ##Объявляем  переменные, если они не попадут в выборку, то у них будет значение
   
   $strType = "direct-event"
   $strCategory = "squid"
   $strObjectType = "Web Site"
   $login = "none"
   $strHost = "none"
   $strAction = "none"
   $strContents = "none"

   ##Пробегаемся по всей строке и ищем 
   foreach ($find in $splitArray)
   {
    if ($find -like '*@*')##Запись с собакой, такая есть только у пользователя
    {
      $login = $find ##записываем в переменную
    }
    if (($find -like '*.*.*.*') -and ($find -notlike '*/*'))##аналогично запись IP без слэша
    {
      $strHost = $find ##записываем в переменную
    } 
    if (($find -like 'POST') -or ($find -like 'GET') -or ($find -like 'CONNECT')) ##Аналогично ищем запись содержащую пост, гет или коннект
    {
        $strAction = $find ##записываем в переменную
    }
    if ($find -like 'http*') ##Аналогично ищем запись содержащую http*
    {
        $strContents = "$find"##записываем в переменную
    }   

 }
    
    ## Конвертируем дату в нужный формат
    $UnixTime = $splitArray[0]
    $startdate = Get-Date –Date '01/01/1970' 
    $timespan = New-Timespan -Seconds $UnixTime
    $strDate = $startdate + $timespan
  
    ##Создаем хэштаблицу на основе наших данных
 $dataTable = [pscustomobject]@{
 Time = $strDate.ToString("dd.MM.yyyy HH:mm:ss")
 Type = $strType
 Category = $strCategory
 Object_type = $strObjectType
 Who = $login
 Where = $strHost
 Action = $strAction
 Contents = $strContents
 }
 
 #Записываем данные в Json файл (честно украденная у Максима логика)

 $dataTable | Add-Member -MemberType NoteProperty -Name Forwarder -Value "event-direct" -Force ##Создали объект из хэш таблицы
 $JSON = $dataTable | ConvertTo-Json ##Сконвертировали в джейсон
 $JSON | Out-File -FilePath $outFileName -Encoding UTF8 -Append ##добавили к файлу

 ##И так получается N раз, в зависимости от количества записей в логе.
  } 
 
