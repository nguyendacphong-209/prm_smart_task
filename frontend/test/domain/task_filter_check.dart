import 'package:prm_smart_task/features/task/domain/entities/app_task.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_filter.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_assignee_detail.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_label_detail.dart';
void main() {
 final now=DateTime.utc(2026,11,3);
 final tasks=[
  AppTask(id:'a',projectId:'p',title:'Fix LOGIN',priority:'high',statusId:'todo',deadline:now.subtract(const Duration(days:1)),assignees:const [TaskAssigneeDetail(userId:'u',email:'u@test.com',fullName:'User')],labels:const [TaskLabelDetail(id:'bug',name:'Bug')]),
  AppTask(id:'b',projectId:'p',title:'Login UI',priority:'low',statusId:'doing',deadline:now.add(const Duration(days:1))),
  const AppTask(id:'c',projectId:'p',title:'Docs',priority:'medium'),
 ];
 void check(bool ok,String name) { if(!ok) throw StateError(name); print('PASS: $name'); }
 check(filterTasks(tasks,query:'  LOGIN ',now:now).length==2,'trim and case-insensitive title');
 check(filterTasks(tasks,query:'login',statusId:'todo',assigneeId:'u',priority:'high',labelId:'bug',overdueOnly:true,now:now).single.id=='a','combined filters');
 check(filterTasks(tasks,assigneeId:'missing',now:now).isEmpty,'no matching assignee');
 check(filterTasks(tasks,overdueOnly:true,now:now).single.id=='a','past deadline excludes future and missing');
 check(filterTasks(tasks,deadlineOrder:1,now:now).map((t)=>t.id).join()== 'abc','ascending null last');
 check(filterTasks(tasks,deadlineOrder:-1,now:now).map((t)=>t.id).join()== 'bac','descending null last');
 check(tasks.map((t)=>t.id).join()=='abc','source list unchanged');
 check(filterTasks(tasks,now:now).length==3,'reset returns all');
 check(filterTasks([AppTask(id:'d',projectId:'p',title:'Boundary',priority:'low',deadline:now)],overdueOnly:true,now:now).isEmpty,'exact deadline is not past');
}
