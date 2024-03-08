public with sharing class LightningEventsController {

    @AuraEnabled
    public static Map<String, Integer> getEventsCount() {
        Integer todayEvents = [
            SELECT count()
            FROM Event
            WHERE OwnerId = :UserInfo.getUserId()
            AND (
                StartDateTime >= :Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0))
                AND StartDateTime < :Datetime.newInstance(Date.today().addDays(1), Time.newInstance(0, 0, 0, 0))
            )
        ];

        Integer tomorrowEvents = [
            SELECT count()
            FROM Event
            WHERE OwnerId = :UserInfo.getUserId()
            AND (
                StartDateTime >= :Datetime.newInstance(Date.today().addDays(1), Time.newInstance(0, 0, 0, 0))
                AND StartDateTime < :Datetime.newInstance(Date.today().addDays(2), Time.newInstance(0, 0, 0, 0))
            )
        ];

        Integer thisWeekEvents = [
            SELECT count()
            FROM Event
            WHERE OwnerId = :UserInfo.getUserId()
            AND (
                StartDateTime >= :Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0))
                AND StartDateTime < :Datetime.newInstance(Date.today().addDays(8), Time.newInstance(0, 0, 0, 0))
            )
        ];

        Integer thisMonthEvents = [
            SELECT count()
            FROM Event
            WHERE OwnerId = :UserInfo.getUserId()
            AND (
                StartDateTime >= :Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0))
                AND StartDateTime < :Datetime.newInstance(Date.today().toStartOfMonth().addMonths(1), Time.newInstance(0, 0, 0, 0))
            )
        ];

        return new Map<String, Integer> {
            'today' => todayEvents,
            'tomorrow' => tomorrowEvents,
            'week' => thisWeekEvents,
            'month' => thisMonthEvents
        };
    }

    @AuraEnabled
    public static List<Event> getEvents(String mode) {
        if (mode == 'today') {
            return [
                SELECT Id, Location, StartDateTime, EndDateTime, Subject, What.Name, What.Id, Status__c
                FROM Event
                WHERE OwnerId = :UserInfo.getUserId()
                AND (
                    StartDateTime >= :Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0))
                    AND StartDateTime < :Datetime.newInstance(Date.today().addDays(1), Time.newInstance(0, 0, 0, 0))
                )
                ORDER BY Status__c Asc, StartDateTime
            ];
        }

        if (mode == 'tomorrow') {
            return [
                SELECT Id, Location, StartDateTime, EndDateTime, Subject, What.Name, What.Id, Status__c
                FROM Event
                WHERE OwnerId = :UserInfo.getUserId()
                AND (
                    StartDateTime >= :Datetime.newInstance(Date.today().addDays(1), Time.newInstance(0, 0, 0, 0))
                    AND StartDateTime < :Datetime.newInstance(Date.today().addDays(2), Time.newInstance(0, 0, 0, 0))
                )
                ORDER BY StartDateTime, Status__c Asc
            ];
        }

        if (mode == 'week') {
            return [
                SELECT Id, Location, StartDateTime, EndDateTime, Subject, What.Name, What.Id, Status__c
                FROM Event
                WHERE OwnerId = :UserInfo.getUserId()
                AND (
                    StartDateTime >= :Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0))
                    AND StartDateTime < :Datetime.newInstance(Date.today().addDays(8), Time.newInstance(0, 0, 0, 0))
                )
                ORDER BY StartDateTime, Status__c Asc
            ];
        }

        if (mode == 'month') {
            return [
                SELECT Id, Location, StartDateTime, EndDateTime, Subject, What.Name, What.Id, Status__c
                FROM Event
                WHERE OwnerId = :UserInfo.getUserId()
                AND (
                    StartDateTime >= :Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0))
                    AND StartDateTime < :Datetime.newInstance(Date.today().toStartOfMonth().addMonths(1), Time.newInstance(0, 0, 0, 0))
                )
                ORDER BY StartDateTime, Status__c Asc
            ];
        }

        return null;
    }

}