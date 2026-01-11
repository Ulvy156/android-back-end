import { Controller, Get, Post, Body, Patch, Param } from '@nestjs/common';
import { UserService } from './user.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { Role } from 'prisma/generated/enums';
import { Roles } from 'src/auth/role.decorator';

@Roles(Role.ADMIN)
@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Post()
  create(@Body() createUserDto: CreateUserDto) {
    return this.userService.create(createUserDto);
  }

  @Get()
  findAll() {
    return this.userService.findAll();
  }

  @Roles(Role.STAFF, Role.ADMIN)
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.userService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    return this.userService.update(+id, updateUserDto);
  }

  @Patch('/change-role')
  changeRole(@Body() data: { id: number; role: Role }) {
    return this.userService.changeRole(+data.id, data.role);
  }

  @Patch('/set-lock')
  setLock(@Body() data: { id: number; isLock: boolean }) {
    return this.userService.setLock(+data.id, data.isLock);
  }
}
