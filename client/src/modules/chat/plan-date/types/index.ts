export type DateMode = 'virtual' | 'offline';

export interface Partner {
  id: string;
  name: string;
  avatar: string;
  isOnline: boolean;
}

export interface DateType {
  id: string;
  label: string;
  icon: string;
}

export interface TodoItem {
  id: string | number;
  text: string;
  done: boolean;
}

export interface PlanDateFormData {
  mode: DateMode;
  partner: Partner | null;
  dateType: string;
  selectedDate: Date;
  timeHour: number;
  timeMinute: number;
  timePeriod: 'AM' | 'PM';
  duration: number;
  todos: TodoItem[];
  proposalNote: string;
  partnerNote: string;
  splitYourShare: number;
}
