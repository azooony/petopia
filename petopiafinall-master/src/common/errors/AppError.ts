// src/common/errors/AppError.ts

export enum HttpCode {
  OK = 200,
  CREATED = 201,
  BAD_REQUEST = 400,
  UNAUTHORIZED = 401,
  FORBIDDEN = 403,
  NOT_FOUND = 404,
  CONFLICT = 409,
  INTERNAL_SERVER_ERROR = 500,
}

export class AppError extends Error {
  statusCode: HttpCode; // Changed to use the Enum type
  isOperational: boolean;

  constructor(message: string, statusCode: HttpCode = HttpCode.INTERNAL_SERVER_ERROR) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}


// export class AppError extends Error {

//   statusCode: number;
//   isOperational: boolean;

//   constructor(message: string, statusCode: number = 500) {

//     super(message);

//     this.statusCode = statusCode;
//     this.isOperational = true;

//     Error.captureStackTrace(this, this.constructor);
//   }

// }
